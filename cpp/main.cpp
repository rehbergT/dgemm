#include <cstdio>
#include <random>

#include "../dgemmR/src/dgemm.h"

void printMatrix(double* x, size_t N, size_t M) {
    for (size_t i = 0; i < N; i++) {
        for (size_t j = 0; j < M; j++) {
            printf("%+.6e ", x[INDEX(i, j, N, M)]);
        }
        printf("\n");
    }
}

double sum(double* x, size_t N) {
    double sum = 0.0;
    for (size_t i = 0; i < N; i++)
        sum += x[i];

    return sum;
}

int main() {
    printf("Hello from the pure C++ version!\n");
    size_t M = 400;
    size_t N = 500;
    size_t K = 520;
    size_t repeats = 10;
    size_t global_repeats = 1;
    int verbose = 0;
    int threads = 32;

    double* a = (double*)malloc(M * K * sizeof(double));
    double* b = (double*)malloc(K * N * sizeof(double));
    double* c = (double*)malloc(M * N * sizeof(double));

    std::mt19937_64 mt(std::mt19937_64(42));
    std::uniform_real_distribution<double> rng(0.0, 1.0);

    for (size_t i = 0; i < M * K; i++)
        a[i] = rng(mt);

    for (size_t i = 0; i < K * N; i++)
        b[i] = rng(mt);

    double timet;
    struct timespec ts0, ts1;

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats, dgemm::dgemm_algo::blas,
                       threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C blas:          %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats, dgemm::dgemm_algo::loops,
                       threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C loops:         %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats, dgemm::dgemm_algo::avx2,
                       threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C avx2:          %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats, dgemm::dgemm_algo::avx2_omp,
                       threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C avx2 omp:      %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats, dgemm::dgemm_algo::avx2_tp,
                       threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C avx2 tp:       %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats, dgemm::dgemm_algo::avx512,
                       threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C avx512:        %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats, dgemm::dgemm_algo::avx512_omp,
                       threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C avx512_omp:    %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats, dgemm::dgemm_algo::avx512_tp,
                       threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C avx512_tp:     %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats,
                       dgemm::dgemm_algo::cuda_cublas_s, threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda sp cublas:  %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats,
                       dgemm::dgemm_algo::cuda_cublas_s, threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda sp cublas:  %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats,
                       dgemm::dgemm_algo::cuda_cublas_d, threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda dp cublas:  %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats,
                       dgemm::dgemm_algo::cuda_loops_s, threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda sp loops:   %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));
    clock_gettime(CLOCK_REALTIME, &ts0);

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C(a, b, c, M, K, N, repeats,
                       dgemm::dgemm_algo::cuda_loops_d, threads, verbose);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda loops sp:   %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    // printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    free(a);
    free(b);
    free(c);
    return 0;
}
