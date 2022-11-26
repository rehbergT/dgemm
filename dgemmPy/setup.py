import numpy
from setuptools import setup, Extension, find_packages
from os import path
with open(path.join(path.dirname(__file__), 'README.md')) as f:
    long_description = f.read()

module = Extension('dgemmPy.src',
                   sources=['dgemmPy/src/wrapper.cpp',
                            'dgemmPy/src/dgemm.cpp'],
                   include_dirs=['dgemmPy/src',
                                 numpy.get_include()],
                   language='c++',
                   extra_compile_args=['-Wall', '-std=c++14', '-O3'],
                   extra_link_args=['-lblas'])

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
      ext_modules=[module]
      )
