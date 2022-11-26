import pytest
import numpy as np
import dgemmPy as dg


def equality(N, M, K, algo):
    np.random.seed(1)
    a = np.random.rand(M, K)
    b = np.random.rand(K, N)
    c1 = dg.dgemm(a, b, algo="py_blas")
    c2 = dg.dgemm(a, b, algo=algo)
    diff = np.absolute(c1 - c2)
    return np.sum(diff)


def test_equality_1():
    N = 40
    M = 50
    K = 30
    assert equality(N, M, K, "automatic") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "fallback") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "loops") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "blas") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "avx2") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "avx2_omp") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "avx2_tp") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "avx512") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "avx512_omp") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "avx512_tp") == pytest.approx(0.0, abs=1e-10)
    assert equality(N, M, K, "py_loops") == pytest.approx(0.0, abs=1e-10)
