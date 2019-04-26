"""
Module dgemm

A small module with functions all performing matrix multiplications
"""
import numpy as np


def dgemm_py_loops(matrix_a: np.array, matrix_b: np.array,
                   repeats: int = 1):
    """Bad matrix multiplication using naive for loops

    This function takes two matrices a and b and performs a times b and
    returns the result. The matrix multiplication can be repeated for
    benchmarking.

    Args:
        matrix_a: matrix a
        matrix_b: matrix b
        repeats: determines how often the matrix multiplcation is repeated.

    Returns:
        returns the matrixproduct of a and b
    """
    M = matrix_a.shape[0]
    N = matrix_b.shape[1]
    K = matrix_a.shape[1]

    result = np.empty((M, N))

    for r in range(repeats):
        result.fill(0)

        for m in range(M):
            for n in range(N):

                tmp_sum = 0.0
                for k in range(K):
                    tmp_sum += matrix_a[m, k] * matrix_b[k, n]

                result[m, n] = tmp_sum

    return result
