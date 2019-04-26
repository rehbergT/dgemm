#include <cstdio>
#include <random>

#include "dgemm.h"

void printMatrix(double* x, size_t N, size_t M) {
    return;
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
    size_t M = 4000;
    size_t N = 5000;
    size_t K = 520;
    size_t repeats = 10;
    size_t global_repeats = 20;

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
        dgemm::dgemm_C_blas(a, b, c, M, K, N, repeats);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C blas:          %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C_loops(a, b, c, M, K, N, repeats);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C loops:         %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C_loops_avx(a, b, c, M, K, N, repeats,
                                 dgemm::mtTypes::none);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C loops_avx:     %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C_loops_avx(a, b, c, M, K, N, repeats,
                                 dgemm::mtTypes::openmp);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C loops_avx_omp: %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_C_loops_avx(a, b, c, M, K, N, repeats,
                                 dgemm::mtTypes::stdThreads);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("C loops_avx_pt:  %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::sgemm_cuda_loops(a, b, c, M, K, N, repeats);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda loops_sp:   %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_cuda_loops(a, b, c, M, K, N, repeats);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda loops_dp:   %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));
    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::sgemm_cuda_cublas(a, b, c, M, K, N, repeats);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda blas_sp:    %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));
    printMatrix(c, M, N);
    memset(c, 0.0, M * N * sizeof(double));

    clock_gettime(CLOCK_REALTIME, &ts0);

    for (size_t i = 0; i < global_repeats; i++)
        dgemm::dgemm_cuda_cublas(a, b, c, M, K, N, repeats);

    clock_gettime(CLOCK_REALTIME, &ts1);
    timet = (ts1.tv_sec - ts0.tv_sec) + (ts1.tv_nsec - ts0.tv_nsec) * 1e-9;
    printf("Cuda blas_dp:    %f ms \t checksum: %e\n",
           timet * 1e3 / global_repeats, sum(c, M * N));

    printMatrix(c, M, N);
    free(a);
    free(b);
    free(c);
    return 0;
}
