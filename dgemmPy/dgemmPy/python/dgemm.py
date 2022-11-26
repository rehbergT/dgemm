"""
Module dgemm

A small module with functions all performing matrix multiplications
"""
import numpy as np
from dgemmPy.python.dgemm_py_blas import dgemm_py_blas
from dgemmPy.python.dgemm_py_loops import dgemm_py_loops


def dgemm(matrix_a: np.array, matrix_b: np.array,
          repeats: int = 1,
          algo: str = "py_blas",
          verbose: bool = False):
    """Matrix multiplication using different implementations

    This function takes two matrices a and b and performs a times b and
    returns the result. The matrix multiplication can be repeated for
    benchmarking.

    Args:
        matrix_a: matrix a
        matrix_b: matrix b
        repeats: determines how often the matrix multiplcation is repeated
        algo: select algo
        verbose: enable output

    Returns:
        returns the matrixproduct of a and b
    """

    if algo == "py_loops":
        result = dgemm_py_loops(matrix_a, matrix_b, repeats, verbose)
    elif algo == "py_blas":
        result = dgemm_py_blas(matrix_a, matrix_b, repeats, verbose)

    return result
