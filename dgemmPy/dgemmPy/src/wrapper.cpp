#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION

#include <Python.h>
#include <numpy/arrayobject.h>
#include "dgemm.h"

static PyArrayObject* dgemm_C_loops(PyObject* self, PyObject* args) {
    PyArrayObject* _matrix_a = nullptr;
    PyArrayObject* _matrix_b = nullptr;

    // default repeats should be 1
    int repeats = 1;

    // see https://docs.python.org/3/c-api/arg.html
    // first O! = first argument (a numpy array object)
    //         -> needs 2 arguments: type and add. of a pointer which
    //            should point to the object
    // second 0! = second argument (a numpy array object) as above
    // | remaining arguments are optional
    // i = third argument (a python int) is converted to a C int, if not
    //         provided the int is not changed
    // : ends the argument string
    // the string after : is used as name in exceptions
    if (!PyArg_ParseTuple(args, "O!O!|i:dgemm_C_loops", &PyArray_Type,
                          &_matrix_a, &PyArray_Type, &_matrix_b, &repeats)) {
        return 0;
    }

    // valid if memory is continuous !
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
    // first arg. = 1 vector, 2 matrix, 3 rank3 tensor
    // second arg. =  dimensions
    // third arg. = type
    // forth arg. = column or row wise order
    PyArrayObject* res = (PyArrayObject*)PyArray_ZEROS(2, dims, NPY_DOUBLE, 0);
    double* res_ptr = (double*)PyArray_DATA(res);
    NPY_BEGIN_ALLOW_THREADS
    dgemm::dgemm_C_loops(matrix_a, matrix_b, res_ptr, M, K, N, repeats);
    NPY_END_ALLOW_THREADS

    return res;
}

static PyArrayObject* dgemm_C_blas(PyObject* self, PyObject* args) {
    PyArrayObject* _matrix_a = nullptr;
    PyArrayObject* _matrix_b = nullptr;
    int repeats = 1;
    if (!PyArg_ParseTuple(args, "O!O!|i:dgemm_C_blas", &PyArray_Type,
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
    dgemm::dgemm_C_blas(matrix_a, matrix_b, res_ptr, M, K, N, repeats);
    NPY_END_ALLOW_THREADS

    return res;
}

static PyArrayObject* dgemm_C_loops_avx(PyObject* self, PyObject* args) {
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
    dgemm::dgemm_C_loops_avx(matrix_a, matrix_b, res_ptr, M, K, N, repeats,
                             dgemm::mtTypes::none);
    NPY_END_ALLOW_THREADS

    return res;
}
static PyArrayObject* dgemm_C_loops_avx_omp(PyObject* self, PyObject* args) {
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
    dgemm::dgemm_C_loops_avx(matrix_a, matrix_b, res_ptr, M, K, N, repeats,
                             dgemm::mtTypes::openmp);
    NPY_END_ALLOW_THREADS

    return res;
}

static PyArrayObject* dgemm_C_loops_avx_tp(PyObject* self, PyObject* args) {
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
    dgemm::dgemm_C_loops_avx(matrix_a, matrix_b, res_ptr, M, K, N, repeats,
                             dgemm::mtTypes::stdThreads);
    NPY_END_ALLOW_THREADS

    return res;
}

static PyMethodDef methods[] = {
    {"dgemm_C_loops", (PyCFunction)dgemm_C_loops, METH_VARARGS,
     "A function that performs a matrix multiplication using naive loops."},
    {"dgemm_C_blas", (PyCFunction)dgemm_C_blas, METH_VARARGS,
     "A function that performs a matrix multiplication using BLAS."},
    {"dgemm_C_loops_avx", (PyCFunction)dgemm_C_loops_avx, METH_VARARGS,
     "A function that performs a matrix multiplication using naive loops using "
     "avx instructions."},
    {"dgemm_C_loops_avx_omp", (PyCFunction)dgemm_C_loops_avx_omp, METH_VARARGS,
     "A function that performs a matrix multiplication using naive loops using "
     "avx instructions and openmp parallelization."},
    {"dgemm_C_loops_avx_tp", (PyCFunction)dgemm_C_loops_avx_tp, METH_VARARGS,
     "A function that performs a matrix multiplication using naive loops using "
     "avx instructions and a threadpool parallelization."},
    {NULL, NULL, 0, NULL} /* Sentinel */
};

static struct PyModuleDef module = {PyModuleDef_HEAD_INIT,
                                    "src",      /* name of module */
                                    "C module", /* module documentation */
                                    -1, methods};

PyMODINIT_FUNC PyInit_src(void) {
    // required to prevent segfaults, see
    // https://docs.scipy.org/doc/numpy/reference/c-api.array.html?highlight=import_array#c.import_array
    import_array();

    PyObject* m = PyModule_Create(&module);
    if (m == NULL) {
        return NULL;
    }
    return m;
}