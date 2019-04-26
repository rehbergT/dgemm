#include "dgemm.h"

void dgemm::dgemm_C_loops(double* matrix_a,
                          double* matrix_b,
                          double* result,
                          int M,
                          int K,
                          int N,
                          int repeats) {
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

void dgemm::dgemm_C_blas(double* matrix_a,
                         double* matrix_b,
                         double* result,
                         int M,
                         int K,
                         int N,
                         int repeats) {
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

void dgemm::dgemm_C_loops_avx(double* matrix_a,
                              double* matrix_b,
                              double* result,
                              int M,
                              int K,
                              int N,
                              int repeats,
                              int parallelization) {
    int alignedDoubles, alignment, avxType;

    // check which avx type is supported by the cpu
    if (__builtin_cpu_supports("avx2")) {
        avxType = avx2;
        alignedDoubles = 4;
        alignment = 32;
    } else if (__builtin_cpu_supports("avx512f")) {
        avxType = avx512;
        alignedDoubles = 8;
        alignment = 64;
    } else {
        avxType = fallback;
        dgemm_C_loops(matrix_a, matrix_b, result, M, K, N, repeats);
        return;
    }

    // the following deep copies the matrices because:
    // 1. max. cache utilization: A stored in row-major order,
    //                            B stored in col-major order
    // 2. avx instruction rely on aligned memory = the memory address of the
    //    first element of each col (col-major order) or. row (row-major order)
    //    must be a multiple of alignedDoubles -> add zero-padding
    int memory_K = K;
    if (memory_K % alignedDoubles != 0)
        memory_K += alignedDoubles - memory_K % alignedDoubles;

    double* aligned_a =
        (double*)ALIGNED_ALLOC(alignment, M * memory_K * sizeof(double));
    double* aligned_b =
        (double*)ALIGNED_ALLOC(alignment, memory_K * N * sizeof(double));

    memset(aligned_a, 0.0, M * memory_K * sizeof(double));
    memset(aligned_b, 0.0, memory_K * N * sizeof(double));

    // pay attention to the order of the loops!
    for (int m = 0; m < M; m++) {
        for (int k = 0; k < K; k++) {
            aligned_a[INDEX_ROW(m, k, M, memory_K)] =
                matrix_a[INDEX(m, k, M, K)];
        }
    }

    // pay attention to the order of the loops!
    for (int n = 0; n < N; n++) {
        for (int k = 0; k < K; k++) {
            aligned_b[INDEX_COL(k, n, memory_K, N)] =
                matrix_b[INDEX(k, n, K, N)];
        }
    }

    if (avxType == avx2) {
        if (parallelization == none) {
            dgemm_C_loops_avx2(aligned_a, aligned_b, result, M, memory_K, N,
                               repeats);
        } else if (parallelization == openmp) {
            dgemm_C_loops_avx2_omp(aligned_a, aligned_b, result, M, memory_K, N,
                                   repeats);
        } else {
            dgemm_C_loops_avx2_tp(aligned_a, aligned_b, result, M, memory_K, N,
                                  repeats);
        }
    } else if (avxType == avx512) {
        if (parallelization == none) {
            dgemm_C_loops_avx512(aligned_a, aligned_b, result, M, memory_K, N,
                                 repeats);
        } else if (parallelization == openmp) {
            dgemm_C_loops_avx512_omp(aligned_a, aligned_b, result, M, memory_K,
                                     N, repeats);
        } else {
            dgemm_C_loops_avx512_tp(aligned_a, aligned_b, result, M, memory_K,
                                    N, repeats);
        }
    } else {
        // should never happen due to the return above!
    }

    ALIGNED_FREE(aligned_a);
    ALIGNED_FREE(aligned_b);
}
