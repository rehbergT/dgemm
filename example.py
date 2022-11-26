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
c7 = dg.dgemm(a, b, algo="avx512", verbose=True)

print(np.sum(c0 - c1))
print(np.sum(c0 - c2))
print(np.sum(c0 - c3))
print(np.sum(c0 - c4))
print(np.sum(c0 - c5))
print(np.sum(c0 - c6))
print(np.sum(c0 - c7))


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
      "C_avx512:                     {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="avx512")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
