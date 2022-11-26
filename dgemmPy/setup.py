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
                self.compiler.set_executable('compiler_so', 'nvcc')
                postargs = postargs['nvcc']
            else:
                self.compiler.set_executable('compiler_so', 'g++')
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
                            'dgemmPy/src/dgemm_cuda.cu'
                            ],
                   include_dirs=['dgemmPy/src',
                                 numpy.get_include(),
                                 path.join(CUDA_HOME, 'include')],
                   library_dirs=[path.join(CUDA_HOME, 'lib64')],
                   runtime_library_dirs=[path.join(CUDA_HOME, 'lib64')],
                   language='c++',
                   extra_compile_args={'cxx': ['-Wall', '-std=c++14', '-O3',
                                               '-fopenmp', '-pthread', '-fPIC'],
                                       'nvcc': ['-arch=sm_61',
                                                '--ptxas-options=-v', '-c',
                                                '--compiler-options',
                                                "'-fPIC'"]},
                   extra_link_args=['-lblas', '-fopenmp', '-lcublas', '-lcudart'])

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
