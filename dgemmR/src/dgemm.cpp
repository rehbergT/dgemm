#include "dgemm.h"

void dgemm::dgemm_C_loops(double* matrix_a,
                          double* matrix_b,
                          double* result,
                          int M,
                          int K,
                          int N,
                          int repeats,
                          int verbose) {
    if (verbose)
        PRINT("Using C-loops version\n");
    double sum;

    for (int r = 0; r < repeats; r++) {
        for (int m = 0; m < M; m++) {
            for (int n = 0; n < N; n++) {
                sum = 0.0;
                for (int k = 0; k < K; k++) {
                    sum += matrix_a[INDEX(m, k, M, K)] *
                           matrix_b[INDEX(k, n, K, N)];
                }
                result[INDEX(m, n, M, N)] = sum;
            }
        }
    }
}

void dgemm::dgemm_C_fallback(double* matrix_a,
                             double* matrix_b,
                             double* result,
                             int M,
                             int K,
                             int N,
                             int repeats,
                             int verbose) {
    if (verbose)
        PRINT("Fallback version\n");
    dgemm_C_blas(matrix_a, matrix_b, result, M, K, N, repeats, verbose);
}

void dgemm::dgemm_C_blas(double* matrix_a,
                         double* matrix_b,
                         double* result,
                         int M,
                         int K,
                         int N,
                         int repeats,
                         int verbose) {
    if (verbose)
        PRINT("Using BLAS version\n");
    char transpose = 'N';
    double one = 1.0;
    double zero = 0.0;

    for (int r = 0; r < repeats; r++) {
        // calculates  c = alpha * a %*% b + beta * c
#ifdef COLUMN_MAJOR
        dgemm_(&transpose,  // no transpose of matrix_a
               &transpose,  // no transpose of matrix_b
               &M,          // number of rows of matrix_a
               &N,          // number of cols of matrix_b
               &K,          // number of cols of matrix_a
               &one,        // scalar multiplication with alpha, not need -> 1
               matrix_a,    // matrix_a
               &M,          // lda: logical size of 1. dim in mem of matrix_a
               matrix_b,    // matrix_b
               &K,          // ldb: logical size of 1. dim in mem of matrix_b
               &zero,       // scalar multiplication with beta, not need -> 1
               result,      // result matrix c
               &M           // ldc: logical size of 1. dim in mem of matrix_c
        );
#else
        // we can use BLAS despite row-wise stored data using
        // B^T * A^T = (A*B)^T
        // note that the result is already in the right order due to the ^T
        dgemm_(&transpose,  // no transpose of matrix_b^T
               &transpose,  // no transpose of matrix_b^T
               &N,          // number of rows of matrix_b^T
               &M,          // number of cols of matrix_a^T
               &K,          // number of cols of matrix_b^T
               &one,        // scalar multiplication with alpha, not need -> 1
               matrix_b,    // matrix_b^T
               &N,          // lda: logical size of 1. dim in mem of matrix_b^T
               matrix_a,    // matrix_a^T
               &K,          // ldb: logical size of 1. dim in mem of matrix_a^T
               &zero,       // scalar multiplication with beta, not need -> 1
               result,      // result matrix c
               &N           // ldc: logical size of 1. dim in mem of matrix_c^T
        );
#endif
    }
}

void dgemm::dgemm_C(double* matrix_a,
                    double* matrix_b,
                    double* result,
                    int M,
                    int K,
                    int N,
                    int repeats,
                    int algo,
                    int threads,
                    int verbose) {
    if (algo == automatic) {
        if (verbose)
            PRINT("Automatic Detection\n");

        algo = fallback;
        if (__builtin_cpu_supports("avx2"))
            algo = avx2;

        if (__builtin_cpu_supports("avx512f"))
            algo = avx512;

        if (check_cuda_support(verbose))
            algo = cuda_cublas_d;
    }

    switch (algo) {
        case loops:
            dgemm_C_loops(matrix_a, matrix_b, result, M, K, N, repeats,
                          verbose);
            break;
        case blas:
            dgemm_C_blas(matrix_a, matrix_b, result, M, K, N, repeats, verbose);
            break;
        case avx2:
            dgemm_C_loops_avx2(matrix_a, matrix_b, result, M, K, N, repeats,
                               threads, verbose, 0);
            break;
        case avx2_omp:
            dgemm_C_loops_avx2(matrix_a, matrix_b, result, M, K, N, repeats,
                               threads, verbose, 1);
            break;
        case avx2_tp:
            dgemm_C_loops_avx2(matrix_a, matrix_b, result, M, K, N, repeats,
                               threads, verbose, 2);
            break;
        case avx512:
            dgemm_C_loops_avx512(matrix_a, matrix_b, result, M, K, N, repeats,
                                 threads, verbose, 0);
            break;
        case avx512_omp:
            dgemm_C_loops_avx512(matrix_a, matrix_b, result, M, K, N, repeats,
                                 threads, verbose, 1);
            break;
        case avx512_tp:
            dgemm_C_loops_avx512(matrix_a, matrix_b, result, M, K, N, repeats,
                                 threads, verbose, 2);
            break;
        case cuda_cublas_s:
            sgemm_cuda_cublas(matrix_a, matrix_b, result, M, K, N, repeats,
                              verbose);
            break;
        case cuda_cublas_d:
            dgemm_cuda_cublas(matrix_a, matrix_b, result, M, K, N, repeats,
                              verbose);
            break;
        case cuda_loops_s:
            sgemm_cuda_loops(matrix_a, matrix_b, result, M, K, N, repeats,
                             verbose);
            break;
        case cuda_loops_d:
            dgemm_cuda_loops(matrix_a, matrix_b, result, M, K, N, repeats,
                             verbose);
            break;
        case fallback:
            dgemm_C_fallback(matrix_a, matrix_b, result, M, K, N, repeats,
                             verbose);
            break;
        default:
            dgemm_C_fallback(matrix_a, matrix_b, result, M, K, N, repeats,
                             verbose);
    }
}
