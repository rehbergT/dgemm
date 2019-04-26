#include "dgemm.h"

void dgemm::sgemm_cuda_loops(double* matrix_a,
                             double* matrix_b,
                             double* result,
                             int M,
                             int K,
                             int N,
                             int repeats) {
    static bool printed_error = false;

    if (printed_error == false) {
        printf("Fall back to C blas! Not compiled with cuda!\n");
        printed_error = true;
    }
    dgemm_C_blas(matrix_a, matrix_b, result, M, K, N, repeats);
}

void dgemm::dgemm_cuda_loops(double* matrix_a,
                             double* matrix_b,
                             double* result,
                             int M,
                             int K,
                             int N,
                             int repeats) {
    static bool printed_error = false;

    if (printed_error == false) {
        printf("Fall back to C blas! Not compiled with cuda!\n");
        printed_error = true;
    }
    dgemm_C_blas(matrix_a, matrix_b, result, M, K, N, repeats);
}

void dgemm::sgemm_cuda_cublas(double* matrix_a,
                              double* matrix_b,
                              double* result,
                              int M,
                              int K,
                              int N,
                              int repeats) {
    static bool printed_error = false;

    if (printed_error == false) {
        printf("Fall back to C blas! Not compiled with cuda!\n");
        printed_error = true;
    }
    dgemm_C_blas(matrix_a, matrix_b, result, M, K, N, repeats);
}

void dgemm::dgemm_cuda_cublas(double* matrix_a,
                              double* matrix_b,
                              double* result,
                              int M,
                              int K,
                              int N,
                              int repeats) {
    static bool printed_error = false;

    if (printed_error == false) {
        printf("Fall back to C blas! Not compiled with cuda!\n");
        printed_error = true;
    }
    dgemm_C_blas(matrix_a, matrix_b, result, M, K, N, repeats);
}