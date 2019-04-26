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
# build the package
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

c1 = dg.dgemm_py_blas(a, b)
c2 = dg.dgemm_py_loops(a, b)
c3 = dg.dgemm_C_loops(a, b)
c4 = dg.dgemm_C_blas(a, b)
c5 = dg.dgemm_C_loops_avx(a, b)
c6 = dg.dgemm_C_loops_avx_omp(a, b)
c7 = dg.dgemm_C_loops_avx_tp(a, b)
# c8 = dg.sgemm_cuda_loops(a, b)
# c9 = dg.dgemm_cuda_loops(a, b)
# c10 = dg.sgemm_cuda_cublas(a, b)
# c11 = dg.dgemm_cuda_cublas(a, b)

print(np.sum(c1 - c2))
print(np.sum(c1 - c3))
print(np.sum(c1 - c4))
print(np.sum(c1 - c5))
print(np.sum(c1 - c6))
print(np.sum(c1 - c7))
# print(np.sum(c1 - c8))
# print(np.sum(c1 - c9))
# print(np.sum(c1 - c10))
# print(np.sum(c1 - c11))

repeats = 10
global_repeats = 20

print("py_blas:                      {:f} ms".format(
    timeit.timeit(stmt="dg.dgemm_py_blas(a, b, repeats)",
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
print("py_loops:                     {:f} ms".format(
    timeit.timeit(stmt="dg.dgemm_py_loops(a, b, repeats)",
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
print("C_loops:                      {:f} ms".format(
    timeit.timeit(stmt="dg.dgemm_C_loops(a, b, repeats)",
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
print("C_blas:                       {:f} ms".format(
    timeit.timeit(stmt="dg.dgemm_C_blas(a, b, repeats)",
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
print("C_loops_avx:                  {:f} ms".format(
    timeit.timeit(stmt="dg.dgemm_C_loops_avx(a, b, repeats)",
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
print("C_loops_avx_omp:              {:f} ms".format(
    timeit.timeit(stmt="dg.dgemm_C_loops_avx_omp(a, b, repeats)",
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
print("C_loops_avx_tp:               {:f} ms".format(
    timeit.timeit(stmt="dg.dgemm_C_loops_avx_tp(a, b, repeats)",
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
# print("cuda_loops_sp:              {:f} ms".format(
#     timeit.timeit(stmt="dg.sgemm_cuda_loops(a, b, repeats)",
#                   number=global_repeats,
#                   globals=globals()) * 1e3 / global_repeats))
# print("cuda_loops_dp:              {:f} ms".format(
#     timeit.timeit(stmt="dg.dgemm_cuda_loops(a, b, repeats)",
#                   number=global_repeats,
#                   globals=globals()) * 1e3 / global_repeats))
# print("cuda_cublas:                {:f} ms".format(
#     timeit.timeit(stmt="dg.sgemm_cuda_cublas(a, b, repeats)",
#                   number=global_repeats,
#                   globals=globals()) * 1e3 / global_repeats))
# print("cuda_cublas:                {:f} ms".format(
#     timeit.timeit(stmt="dg.dgemm_cuda_cublas(a, b, repeats)",
#                   number=global_repeats,
#                   globals=globals()) * 1e3 / global_repeats))
