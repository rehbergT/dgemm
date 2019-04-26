"""
Module dgemm

A small module with functions all performing matrix multiplications
"""
import numpy as np


def dgemm_py_blas(matrix_a: np.array, matrix_b: np.array,
                  repeats: int = 1):
    """Good matrix multiplication using the buildin numpy function

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
    result = np.empty((matrix_a.shape[0], matrix_b.shape[1]))
    for r in range(repeats):
        result = np.matmul(matrix_a, matrix_b)

    return result
