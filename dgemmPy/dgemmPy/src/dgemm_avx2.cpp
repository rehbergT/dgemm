#include "dgemm.h"

void dgemm::dgemm_C_loops_avx2(double* matrix_a,
                               double* matrix_b,
                               double* result,
                               int M,
                               int K,
                               int N,
                               int repeats,
                               int threads,
                               int verbose,
                               int parallelization) {
    if (verbose)
        PRINT("Using AVX2 version\n");

    if (!__builtin_cpu_supports("avx2")) {
        if (verbose)
            PRINT(
                "CPUs does not support AVX2. Defaulting to fallback "
                "version.\n");
        dgemm_C_fallback(matrix_a, matrix_b, result, M, K, N, repeats, verbose);
        return;
    }

    int alignedDoubles = 4;
    int alignment = 32;

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
        (double*)_mm_malloc(M * memory_K * sizeof(double), alignment);
    double* aligned_b =
        (double*)_mm_malloc(memory_K * N * sizeof(double), alignment);

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

    for (int r = 0; r < repeats; r++) {
        if (parallelization == 0) {
            for (int m = 0; m < M; m++) {
                double *_a, *_b, *_c;
                __m256d a, b, c;
                for (int n = 0; n < N; n++) {
                    _a = &aligned_a[m *
                                    memory_K];  // INDEX_ROW(m, 0, M, K) = m * K
                    _b = &aligned_b[n *
                                    memory_K];  // INDEX_COL(0, n, K, N) = n * K

                    c = _mm256_setzero_pd();
                    for (int k = 0; k < memory_K; k += 4) {
                        a = _mm256_load_pd(&_a[k]);
                        b = _mm256_load_pd(&_b[k]);
                        c = _mm256_fmadd_pd(a, b, c);  // c = a * b + c
                    }

                    _c = (double*)&c;
                    result[INDEX(m, n, M, N)] = _c[0] + _c[1] + _c[2] + _c[3];
                }
            }
        } else if (parallelization == 1) {
            int maxThreads = omp_get_max_threads();
            if (threads > maxThreads)
                threads = maxThreads;

            omp_set_num_threads(threads);
            if (verbose)
                PRINT("Using OMP with %d threads\n", threads);
#pragma omp parallel for
            for (int m = 0; m < M; m++) {
                double *_a, *_b, *_c;
                __m256d a, b, c;
                for (int n = 0; n < N; n++) {
                    _a = &aligned_a[m *
                                    memory_K];  // INDEX_ROW(m, 0, M, K) = m * K
                    _b = &aligned_b[n *
                                    memory_K];  // INDEX_COL(0, n, K, N) = n * K

                    c = _mm256_setzero_pd();
                    for (int k = 0; k < memory_K; k += 4) {
                        a = _mm256_load_pd(&_a[k]);
                        b = _mm256_load_pd(&_b[k]);
                        c = _mm256_fmadd_pd(a, b, c);  // c = a * b + c
                    }

                    _c = (double*)&c;
                    result[INDEX(m, n, M, N)] = _c[0] + _c[1] + _c[2] + _c[3];
                }
            }
        } else if (parallelization == 2) {
            int maxThreads = std::thread::hardware_concurrency();
            if (threads > maxThreads)
                threads = maxThreads;

            if (verbose)
                PRINT("Using my thread pool with %d threads\n", threads);

            Parallel par(maxThreads);
            par.doParallelChunked(M, [&](size_t m) {
                double *_a, *_b, *_c;
                __m256d a, b, c;
                for (int n = 0; n < N; n++) {
                    _a = &aligned_a[m *
                                    memory_K];  // INDEX_ROW(m, 0, M, K) = m * K
                    _b = &aligned_b[n *
                                    memory_K];  // INDEX_COL(0, n, K, N) = n * K

                    c = _mm256_setzero_pd();
                    for (int k = 0; k < memory_K; k += 4) {
                        a = _mm256_load_pd(&_a[k]);
                        b = _mm256_load_pd(&_b[k]);
                        c = _mm256_fmadd_pd(a, b, c);  // c = a * b + c
                    }

                    _c = (double*)&c;
                    result[INDEX(m, n, M, N)] = _c[0] + _c[1] + _c[2] + _c[3];
                }
            });
        }
    }
    _mm_free(aligned_a);
    _mm_free(aligned_b);
}
