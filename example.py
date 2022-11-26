# you can install the python module from the local file system
#   pip3 install ./dgemmPy
#   pip3 install ./dgemmPy --verbose
#
# you can install the python module in editable mode for developing
#   pip3 install -e ./dgemmPy
#
# you can uninstall the python module with
#   pip3 uninstall dgemmPy
#
# create source package
#   python3 setup.py sdist
#
# build the package (clean with python3 setup.py clean --all)
#   python3 setup.py build
#
# run unit tests with
#   python3 -m pytest
#
# prevent local path import (C++ module import would fail)
from __future__ import absolute_import
import timeit
import numpy as np
import dgemmPy as dg


np.random.seed(1)

M = 40
N = 500
K = 52

a = np.random.rand(M, K)
b = np.random.rand(K, N)

c0 = dg.dgemm(a, b, algo="py_blas", verbose=True)
c1 = dg.dgemm(a, b, algo="py_loops", verbose=True)
c2 = dg.dgemm(a, b, algo="loops", verbose=True)
c3 = dg.dgemm(a, b, algo="blas", verbose=True)
c4 = dg.dgemm(a, b, algo="automatic", verbose=True)
c5 = dg.dgemm(a, b, algo="fallback", verbose=True)
c6 = dg.dgemm(a, b, algo="avx2", verbose=True)
c7 = dg.dgemm(a, b, algo="avx2_omp", verbose=True)
c8 = dg.dgemm(a, b, algo="avx2_tp", verbose=True)
c9 = dg.dgemm(a, b, algo="avx512", verbose=True)
c10 = dg.dgemm(a, b, algo="avx512_omp", verbose=True)
c11 = dg.dgemm(a, b, algo="avx512_tp", verbose=True)
c12 = dg.dgemm(a, b, algo="cuda_cublas_s", verbose=True)
c13 = dg.dgemm(a, b, algo="cuda_cublas_d", verbose=True)
c14 = dg.dgemm(a, b, algo="cuda_loops_s", verbose=True)
c15 = dg.dgemm(a, b, algo="cuda_loops_d", verbose=True)

print(np.sum(c0 - c1))
print(np.sum(c0 - c2))
print(np.sum(c0 - c3))
print(np.sum(c0 - c4))
print(np.sum(c0 - c5))
print(np.sum(c0 - c6))
print(np.sum(c0 - c7))
print(np.sum(c0 - c8))
print(np.sum(c0 - c9))
print(np.sum(c0 - c10))
print(np.sum(c0 - c11))
print(np.sum(c0 - c12))
print(np.sum(c0 - c13))
print(np.sum(c0 - c14))
print(np.sum(c0 - c15))


repeats = 3
global_repeats = 10

print("py_blas:                      {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="py_blas")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "py_loops:                     {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="py_loops")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "C_loops:                      {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="loops")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "C_blas:                       {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="blas")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "py_automatic:                 {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="automatic")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "py_fallback:                  {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="fallback")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "C_avx2:                       {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="avx2")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "C_avx2_omp:                   {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="avx2_omp")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "C_avx2_tp:                    {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="avx2_tp")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "C_avx512:                     {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="avx512")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "C_avx512_omp:                 {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="avx512_omp")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "C_avx512_tp:                  {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="avx512_tp")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "cuda_loops_sp:                {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="cuda_loops_s")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "cuda_loops_dp:                {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="cuda_loops_d")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "cuda_cublas:                  {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="cuda_cublas_s")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "cuda_cublas:                  {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="cuda_cublas_d")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
