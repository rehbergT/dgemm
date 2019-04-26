#include <cublas_v2.h>
#include "dgemm.h"

void catchCudaError(const char* file, int line) {
    cudaError_t e = cudaGetLastError();
    if (e != cudaSuccess) {
        printf("Cuda-Error: %s %s %d\n", cudaGetErrorString(e), file, line);
        cudaDeviceReset();
        exit(0);
    }
}

__global__ void cuda_sgemm(float* matrix_a,
                           float* matrix_b,
                           float* matrix_c,
                           size_t M,
                           size_t K,
                           size_t N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    float sum = 0;
    if (col < N && row < M) {
        for (int k = 0; k < K; k++) {
            sum +=
                matrix_a[INDEX(row, k, M, K)] * matrix_b[INDEX(k, col, K, N)];
        }
        matrix_c[INDEX(row, col, M, N)] = sum;
    }
}

__global__ void cuda_dgemm(double* matrix_a,
                           double* matrix_b,
                           double* matrix_c,
                           size_t M,
                           size_t K,
                           size_t N) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    double sum = 0;
    if (col < N && row < M) {
        for (int k = 0; k < K; k++) {
            sum +=
                matrix_a[INDEX(row, k, M, K)] * matrix_b[INDEX(k, col, K, N)];
        }
        matrix_c[INDEX(row, col, M, N)] = sum;
    }
}

void dgemm::sgemm_cuda_loops(double* matrix_a,
                             double* matrix_b,
                             double* result,
                             int M,
                             int K,
                             int N,
                             int repeats) {
    size_t sizeA = M * K;
    size_t sizeB = K * N;
    size_t sizeC = M * N;

    float* a = (float*)malloc(sizeA * sizeof(float));
    for (size_t i = 0; i < sizeA; i++)
        a[i] = (float)matrix_a[i];

    float* b = (float*)malloc(sizeB * sizeof(float));
    for (size_t i = 0; i < sizeB; i++)
        b[i] = (float)matrix_b[i];

    float* c = (float*)malloc(sizeC * sizeof(float));

    // allocate array in gpu memory
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, sizeA * sizeof(float));
    cudaMalloc(&d_b, sizeB * sizeof(float));
    cudaMalloc(&d_c, sizeC * sizeof(float));

    cudaMemcpy(d_a, a, sizeA * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeB * sizeof(float), cudaMemcpyHostToDevice);
    catchCudaError(__FILE__, __LINE__);

    size_t block_size = 16;
    size_t grid_rows = ceil((double)M / block_size);
    size_t grid_cols = ceil((double)N / block_size);
    dim3 dimGrid(grid_cols, grid_rows);
    dim3 dimBlock(block_size, block_size);

    // run gpu kernel
    for (int r = 0; r < repeats; r++)
        cuda_sgemm<<<dimGrid, dimBlock>>>(d_a, d_b, d_c, M, K, N);

    catchCudaError(__FILE__, __LINE__);

    // copy results back
    cudaMemcpy(c, d_c, sizeC * sizeof(float), cudaMemcpyDeviceToHost);

    // Free memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Wait for GPU to finish before accessing on host
    cudaDeviceSynchronize();
    catchCudaError(__FILE__, __LINE__);

    for (size_t i = 0; i < sizeC; i++)
        result[i] = (double)c[i];
    free(a);
    free(b);
    free(c);
}

void dgemm::dgemm_cuda_loops(double* matrix_a,
                             double* matrix_b,
                             double* result,
                             int M,
                             int K,
                             int N,
                             int repeats) {
    size_t sizeA = M * K;
    size_t sizeB = K * N;
    size_t sizeC = M * N;

    // allocate array in gpu memory
    double *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, sizeA * sizeof(double));
    cudaMalloc(&d_b, sizeB * sizeof(double));
    cudaMalloc(&d_c, sizeC * sizeof(double));

    cudaMemcpy(d_a, matrix_a, sizeA * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, matrix_b, sizeB * sizeof(double), cudaMemcpyHostToDevice);
    catchCudaError(__FILE__, __LINE__);

    size_t block_size = 16;
    size_t grid_rows = ceil((double)M / block_size);
    size_t grid_cols = ceil((double)N / block_size);
    dim3 dimGrid(grid_cols, grid_rows);
    dim3 dimBlock(block_size, block_size);

    // run gpu kernel
    for (int r = 0; r < repeats; r++)
        cuda_dgemm<<<dimGrid, dimBlock>>>(d_a, d_b, d_c, M, K, N);

    catchCudaError(__FILE__, __LINE__);

    // copy results back
    cudaMemcpy(result, d_c, sizeC * sizeof(double), cudaMemcpyDeviceToHost);

    // Free memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Wait for GPU to finish before accessing on host
    cudaDeviceSynchronize();
    catchCudaError(__FILE__, __LINE__);
}

void dgemm::sgemm_cuda_cublas(double* matrix_a,
                              double* matrix_b,
                              double* result,
                              int M,
                              int K,
                              int N,
                              int repeats) {
    size_t sizeA = M * K;
    size_t sizeB = K * N;
    size_t sizeC = M * N;

    float* a = (float*)malloc(sizeA * sizeof(float));
    for (size_t i = 0; i < sizeA; i++)
        a[i] = (float)matrix_a[i];

    float* b = (float*)malloc(sizeB * sizeof(float));
    for (size_t i = 0; i < sizeB; i++)
        b[i] = (float)matrix_b[i];

    float* c = (float*)malloc(sizeC * sizeof(float));

    // allocate array in gpu memory
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, sizeA * sizeof(float));
    cudaMalloc(&d_b, sizeB * sizeof(float));
    cudaMalloc(&d_c, sizeC * sizeof(float));

    cudaMemcpy(d_a, a, sizeA * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeB * sizeof(float), cudaMemcpyHostToDevice);
    catchCudaError(__FILE__, __LINE__);

    size_t block_size = 16;
    size_t grid_rows = ceil((double)M / block_size);
    size_t grid_cols = ceil((double)N / block_size);
    dim3 dimGrid(grid_cols, grid_rows);
    dim3 dimBlock(block_size, block_size);

    // Create a handle for CUBLAS
    cublasHandle_t handle;
    cublasCreate(&handle);

    // run gpu kernel
    for (int r = 0; r < repeats; r++) {
        float one = 1.0;
        float zero = 0.0;

// Do the actual multiplication
#ifdef COLUMN_MAJOR
        cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, M, N, K, &one, d_a, M,
                    d_b, K, &zero, d_c, M);

#else
        cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, N, M, K, &one, d_b, N,
                    d_a, K, &zero, d_c, N);
#endif
    }

    // Destroy the handle
    cublasDestroy(handle);

    catchCudaError(__FILE__, __LINE__);

    // copy results back
    cudaMemcpy(c, d_c, sizeC * sizeof(float), cudaMemcpyDeviceToHost);

    // Free memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Wait for GPU to finish before accessing on host
    cudaDeviceSynchronize();
    catchCudaError(__FILE__, __LINE__);

    for (size_t i = 0; i < sizeC; i++)
        result[i] = (double)c[i];
    free(a);
    free(b);
    free(c);
}

void dgemm::dgemm_cuda_cublas(double* matrix_a,
                              double* matrix_b,
                              double* result,
                              int M,
                              int K,
                              int N,
                              int repeats) {
    size_t sizeA = M * K;
    size_t sizeB = K * N;
    size_t sizeC = M * N;

    // allocate array in gpu memory
    double *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, sizeA * sizeof(double));
    cudaMalloc(&d_b, sizeB * sizeof(double));
    cudaMalloc(&d_c, sizeC * sizeof(double));

    cudaMemcpy(d_a, matrix_a, sizeA * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, matrix_b, sizeB * sizeof(double), cudaMemcpyHostToDevice);
    catchCudaError(__FILE__, __LINE__);

    size_t block_size = 16;
    size_t grid_rows = ceil((double)M / block_size);
    size_t grid_cols = ceil((double)N / block_size);
    dim3 dimGrid(grid_cols, grid_rows);
    dim3 dimBlock(block_size, block_size);

    // Create a handle for CUBLAS
    cublasHandle_t handle;
    cublasCreate(&handle);

    // run gpu kernel
    for (int r = 0; r < repeats; r++) {
        double one = 1.0;
        double zero = 0.0;

// Do the actual multiplication
#ifdef COLUMN_MAJOR
        cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, M, N, K, &one, d_a, M,
                    d_b, K, &zero, d_c, M);

#else
        cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, N, M, K, &one, d_b, N,
                    d_a, K, &zero, d_c, N);
#endif
    }

    // Destroy the handle
    cublasDestroy(handle);

    catchCudaError(__FILE__, __LINE__);

    // copy results back
    cudaMemcpy(result, d_c, sizeC * sizeof(double), cudaMemcpyDeviceToHost);

    // Free memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Wait for GPU to finish before accessing on host
    cudaDeviceSynchronize();
    catchCudaError(__FILE__, __LINE__);
}
