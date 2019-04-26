#!/usr/bin/env bash

cp cpp/dgemm.h dgemmPy/dgemmPy/src
cp cpp/dgemm_cuda.cu dgemmPy/dgemmPy/src
sed -i -e '1,20d' example.py
sed -i -e 's/\# //g' example.py

cat << 'EOF' > dgemmPy/dgemmPy/__init__.py
from dgemmPy.python.dgemm_py_blas import dgemm_py_blas
from dgemmPy.python.dgemm_py_loops import dgemm_py_loops
from dgemmPy.src import (
    dgemm_C_loops, dgemm_C_blas, dgemm_C_loops_avx,
    dgemm_C_loops_avx_omp, dgemm_C_loops_avx_tp, sgemm_cuda_loops,
    dgemm_cuda_loops, sgemm_cuda_cublas, dgemm_cuda_cublas
)

__all__ = ["dgemm_py_blas", "dgemm_py_loops",
           "dgemm_C_loops", "dgemm_C_blas", "dgemm_C_loops_avx",
           "dgemm_C_loops_avx_omp", "dgemm_C_loops_avx_tp", "sgemm_cuda_loops",
           "dgemm_cuda_loops", "sgemm_cuda_cublas", "dgemm_cuda_cublas"]

EOF


cat << 'EOF' > dgemmPy/setup.py
import copy
import numpy
from setuptools.command.build_ext import build_ext
from setuptools import setup, Extension, find_packages
from os import path
with open(path.join(path.dirname(__file__), 'README.md')) as f:
    long_description = f.read()

# see https://stackoverflow.com/questions/15527611/how-do-i-specify-different-compiler-flags-in-distutils-for-just-one-python-c-ext
# see https://stackoverflow.com/questions/10034325/can-python-distutils-compile-cuda-code
CUDA_HOME = "/usr/local/cuda"


class build_ext_subclass(build_ext):
    def build_extensions(self):
        # tell the compiler it can processes .cu
        self.compiler.src_extensions.append('.cu')
        original__compile = self.compiler._compile

        def new__compile(obj, src, ext, cc_args, extra_postargs, pp_opts):
            postargs = copy.deepcopy(extra_postargs)
            if '.cu' in src:
                # use the cuda for .cu files
                self.compiler.set_executable('compiler_so', 'nvcc')
                # use only a subset of the extra_postargs, which are 1-1
                # translated from the extra_compile_args in the Extension class
                postargs = postargs['nvcc']
            else:
                postargs = postargs['cxx']

            if 'avx2' in src:
                postargs.append("-mavx2")
                postargs.append("-mfma")
            if 'avx512' in src:
                postargs.append("-mavx512f")

            return original__compile(obj, src, ext, cc_args, postargs, pp_opts)

        self.compiler._compile = new__compile
        try:
            build_ext.build_extensions(self)
        finally:
            del self.compiler._compile


module = Extension('dgemmPy.src',
                   sources=['dgemmPy/src/wrapper.cpp',
                            'dgemmPy/src/dgemm.cpp',
                            'dgemmPy/src/dgemm_avx2.cpp',
                            'dgemmPy/src/dgemm_avx512.cpp',
                            'dgemmPy/src/dgemm_cuda.cu'],
                   include_dirs=['dgemmPy/src',
                                 numpy.get_include(),
                                 path.join(CUDA_HOME, 'include')],
                   library_dirs=[path.join(CUDA_HOME, 'lib64')],
                   runtime_library_dirs=[path.join(CUDA_HOME, 'lib64')],
                   language='c++',
                   extra_compile_args={'cxx': ['-DCOL_MAJOR', "-Wall", "-O3",
                                               '-fopenmp', '-std=c++14'],
                                       'nvcc': ['-arch=sm_61',
                                                '--ptxas-options=-v', '-c',
                                                '--compiler-options',
                                                "'-fPIC'"]},
                   extra_link_args=['-lblas', '-lgomp', '-lcublas', '-lcudart'])

setup(name='dgemmPy',
      version='0.0.1',
      description='Example package for showing how to call compiled (C++, '
      'Cuda) code from Python. This package has various functions all '
      'performing simple matrix multiplications.',
      long_description=long_description,
      long_description_content_type="text/markdown",
      author='Thorsten Rehberg',
      author_email='thorsten.rehberg@ur.de',
      url='https://github.com/rehbergT',
      license='MIT',
      packages=find_packages(),
      install_requires=[
          'numpy',
      ],
      classifiers=[
          "Programming Language :: Python :: 3",
          "Operating System :: OS Independent",
      ],
      ext_modules=[module],
      cmdclass={"build_ext": build_ext_subclass}
      )

EOF

cat << 'EOL' > wrapper_insert_temp
static PyArrayObject* sgemm_cuda_loops(PyObject* self, PyObject* args) {
    PyArrayObject* _matrix_a = nullptr;
    PyArrayObject* _matrix_b = nullptr;
    int repeats = 1;
    if (!PyArg_ParseTuple(args, "O!O!|i:dgemm_C_loops", &PyArray_Type,
                          &_matrix_a, &PyArray_Type, &_matrix_b, &repeats)) {
        return 0;
    }

    double* matrix_a = (double*)PyArray_DATA(_matrix_a);
    double* matrix_b = (double*)PyArray_DATA(_matrix_b);

    npy_intp* dims_a = PyArray_DIMS(_matrix_a);
    npy_intp* dims_b = PyArray_DIMS(_matrix_b);

    int M = (int)dims_a[0];
    int N = (int)dims_b[1];
    int K = (int)dims_a[1];

    npy_intp nRows = M;
    npy_intp nCols = N;
    npy_intp dims[2] = {nRows, nCols};
    PyArrayObject* res = (PyArrayObject*)PyArray_ZEROS(2, dims, NPY_DOUBLE, 0);
    double* res_ptr = (double*)PyArray_DATA(res);

    NPY_BEGIN_ALLOW_THREADS
    dgemm::sgemm_cuda_loops(matrix_a, matrix_b, res_ptr, M, K, N, repeats);
    NPY_END_ALLOW_THREADS

    return res;
}

static PyArrayObject* dgemm_cuda_loops(PyObject* self, PyObject* args) {
    PyArrayObject* _matrix_a = nullptr;
    PyArrayObject* _matrix_b = nullptr;
    int repeats = 1;
    if (!PyArg_ParseTuple(args, "O!O!|i:dgemm_C_loops", &PyArray_Type,
                          &_matrix_a, &PyArray_Type, &_matrix_b, &repeats)) {
        return 0;
    }

    double* matrix_a = (double*)PyArray_DATA(_matrix_a);
    double* matrix_b = (double*)PyArray_DATA(_matrix_b);

    npy_intp* dims_a = PyArray_DIMS(_matrix_a);
    npy_intp* dims_b = PyArray_DIMS(_matrix_b);

    int M = (int)dims_a[0];
    int N = (int)dims_b[1];
    int K = (int)dims_a[1];

    npy_intp nRows = M;
    npy_intp nCols = N;
    npy_intp dims[2] = {nRows, nCols};
    PyArrayObject* res = (PyArrayObject*)PyArray_ZEROS(2, dims, NPY_DOUBLE, 0);
    double* res_ptr = (double*)PyArray_DATA(res);

    NPY_BEGIN_ALLOW_THREADS
    dgemm::dgemm_cuda_loops(matrix_a, matrix_b, res_ptr, M, K, N, repeats);
    NPY_END_ALLOW_THREADS

    return res;
}

static PyArrayObject* sgemm_cuda_cublas(PyObject* self, PyObject* args) {
    PyArrayObject* _matrix_a = nullptr;
    PyArrayObject* _matrix_b = nullptr;
    int repeats = 1;
    if (!PyArg_ParseTuple(args, "O!O!|i:dgemm_C_loops", &PyArray_Type,
                          &_matrix_a, &PyArray_Type, &_matrix_b, &repeats)) {
        return 0;
    }

    double* matrix_a = (double*)PyArray_DATA(_matrix_a);
    double* matrix_b = (double*)PyArray_DATA(_matrix_b);

    npy_intp* dims_a = PyArray_DIMS(_matrix_a);
    npy_intp* dims_b = PyArray_DIMS(_matrix_b);

    int M = (int)dims_a[0];
    int N = (int)dims_b[1];
    int K = (int)dims_a[1];

    npy_intp nRows = M;
    npy_intp nCols = N;
    npy_intp dims[2] = {nRows, nCols};
    PyArrayObject* res = (PyArrayObject*)PyArray_ZEROS(2, dims, NPY_DOUBLE, 0);
    double* res_ptr = (double*)PyArray_DATA(res);

    NPY_BEGIN_ALLOW_THREADS
    dgemm::sgemm_cuda_cublas(matrix_a, matrix_b, res_ptr, M, K, N, repeats);
    NPY_END_ALLOW_THREADS

    return res;
}

static PyArrayObject* dgemm_cuda_cublas(PyObject* self, PyObject* args) {
    PyArrayObject* _matrix_a = nullptr;
    PyArrayObject* _matrix_b = nullptr;
    int repeats = 1;
    if (!PyArg_ParseTuple(args, "O!O!|i:dgemm_C_loops", &PyArray_Type,
                          &_matrix_a, &PyArray_Type, &_matrix_b, &repeats)) {
        return 0;
    }

    double* matrix_a = (double*)PyArray_DATA(_matrix_a);
    double* matrix_b = (double*)PyArray_DATA(_matrix_b);

    npy_intp* dims_a = PyArray_DIMS(_matrix_a);
    npy_intp* dims_b = PyArray_DIMS(_matrix_b);

    int M = (int)dims_a[0];
    int N = (int)dims_b[1];
    int K = (int)dims_a[1];

    npy_intp nRows = M;
    npy_intp nCols = N;
    npy_intp dims[2] = {nRows, nCols};
    PyArrayObject* res = (PyArrayObject*)PyArray_ZEROS(2, dims, NPY_DOUBLE, 0);
    double* res_ptr = (double*)PyArray_DATA(res);

    NPY_BEGIN_ALLOW_THREADS
    dgemm::dgemm_cuda_cublas(matrix_a, matrix_b, res_ptr, M, K, N, repeats);
    NPY_END_ALLOW_THREADS

    return res;
}

static PyMethodDef methods[] = {
EOL

sed -i -e '/static PyMethodDef/r wrapper_insert_temp' dgemmPy/dgemmPy/src/wrapper.cpp
sed -i -e '185d' dgemmPy/dgemmPy/src/wrapper.cpp


cat << 'EOL' > wrapper_insert_temp
    {"sgemm_cuda_loops", (PyCFunction)sgemm_cuda_loops, METH_VARARGS,
     "A function that performs a matrix multiplication using a naive single "
     "precision cuda kernel"},
    {"dgemm_cuda_loops", (PyCFunction)dgemm_cuda_loops, METH_VARARGS,
     "A function that performs a matrix multiplication using a naive double "
     "precision cuda kernel"},
    {"sgemm_cuda_cublas", (PyCFunction)sgemm_cuda_cublas, METH_VARARGS,
     "A function that performs a matrix multiplication using the single "
     "precision cublas function"},
    {"dgemm_cuda_cublas", (PyCFunction)dgemm_cuda_cublas, METH_VARARGS,
     "A function that performs a matrix multiplication using the double "
     "precision cublas function"},
EOL
sed -i -e '/avx instructions and a threadpool parallelization/r wrapper_insert_temp' dgemmPy/dgemmPy/src/wrapper.cpp
rm wrapper_insert_temp



cat << 'EOF' > dgemmPy/tests/test_checkForEquality7.py
import pytest
import numpy as np
import dgemmPy as dg


def equality(N, M, K):
    np.random.seed(1)
    a = np.random.rand(M, K)
    b = np.random.rand(K, N)
    c1 = dg.dgemm_py_blas(a, b)
    c2 = dg.sgemm_cuda_loops(a, b)
    diff = np.absolute(c1 - c2)
    return np.sum(diff)


def test_equality_6():
    N = 40
    M = 50
    K = 30
    assert equality(N, M, K) == pytest.approx(0.0, abs=0.1)

EOF

cat << 'EOF' > dgemmPy/tests/test_checkForEquality8.py
import pytest
import numpy as np
import dgemmPy as dg


def equality(N, M, K):
    np.random.seed(1)
    a = np.random.rand(M, K)
    b = np.random.rand(K, N)
    c1 = dg.dgemm_py_blas(a, b)
    c2 = dg.dgemm_cuda_loops(a, b)
    diff = np.absolute(c1 - c2)
    return np.sum(diff)


def test_equality_6():
    N = 40
    M = 50
    K = 30
    assert equality(N, M, K) == pytest.approx(0.0, abs=1e-10)

EOF

cat << 'EOF' > dgemmPy/tests/test_checkForEquality9.py
import pytest
import numpy as np
import dgemmPy as dg


def equality(N, M, K):
    np.random.seed(1)
    a = np.random.rand(M, K)
    b = np.random.rand(K, N)
    c1 = dg.dgemm_py_blas(a, b)
    c2 = dg.sgemm_cuda_cublas(a, b)
    diff = np.absolute(c1 - c2)
    return np.sum(diff)


def test_equality_6():
    N = 40
    M = 50
    K = 30
    assert equality(N, M, K) == pytest.approx(0.0, abs=0.1)

EOF

cat << 'EOF' > dgemmPy/tests/test_checkForEquality10.py
import pytest
import numpy as np
import dgemmPy as dg


def equality(N, M, K):
    np.random.seed(1)
    a = np.random.rand(M, K)
    b = np.random.rand(K, N)
    c1 = dg.dgemm_py_blas(a, b)
    c2 = dg.dgemm_cuda_cublas(a, b)
    diff = np.absolute(c1 - c2)
    return np.sum(diff)


def test_equality_6():
    N = 40
    M = 50
    K = 30
    assert equality(N, M, K) == pytest.approx(0.0, abs=1e-10)

EOF