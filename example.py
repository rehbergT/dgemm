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

print(np.sum(c0 - c1))

repeats = 3
global_repeats = 10

print("py_blas:                      {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="py_blas")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats) +
      "py_loops:                     {:f} ms\n".format(
    timeit.timeit(stmt='dg.dgemm(a, b, repeats, algo="py_loops")',
                  number=global_repeats,
                  globals=globals()) * 1e3 / global_repeats))
