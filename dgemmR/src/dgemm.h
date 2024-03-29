#ifndef DGEMM_H
#define DGEMM_H

#include <immintrin.h>  // used for AVX instrinsics
#include <omp.h>
#include <cstdio>   // for printf
#include <cstdlib>  // for size_t type
#include <cstring>  // used for memset
#include "Parallel.h"

#ifdef R_PACKAGE
#include <R.h>
#include <R_ext/Rdynload.h>
#include <Rinternals.h>
#define PRINT Rprintf
#else
#define PRINT printf
#endif

#define INDEX_COL(i, j, rows, cols) ((i) + ((j) * (rows)))
#define INDEX_ROW(i, j, rows, cols) ((j) + ((i) * (cols)))

#ifdef COLUMN_MAJOR
#define INDEX(i, j, rows, cols) INDEX_COL(i, j, rows, cols)
#else  // ROW_MAJOR
#define INDEX(i, j, rows, cols) INDEX_ROW(i, j, rows, cols)
#endif

extern "C" {
// forward declaration of the blas matrix multiplication since header can
// be missing
// you can look up the declaration probably in /usr/share/R/include/R_ext/BLAS.h
extern void dgemm_(const char* transa,
                   const char* transb,
                   const int* m,
                   const int* n,
                   const int* k,
                   const double* alpha,
                   const double* a,
                   const int* lda,
                   const double* b,
                   const int* ldb,
                   const double* beta,
                   double* c,
                   const int* ldc);
}

namespace dgemm {

enum dgemm_algo {
    automatic = 0,
    fallback = 1,
    loops = 2,
    blas = 3,
    avx2 = 4,
    avx2_omp = 5,
    avx2_tp = 6,
    avx512 = 7,
    avx512_omp = 8,
    avx512_tp = 9,
    cuda_cublas_s = 10,
    cuda_cublas_d = 11,
    cuda_loops_s = 12,
    cuda_loops_d = 13
};

void dgemm_C(double* matrix_a,
             double* matrix_b,
             double* result,
             int M,
             int K,
             int N,
             int repeats,
             int algo,
             int threads,
             int verbose);

void dgemm_C_loops(double* matrix_a,
                   double* matrix_b,
                   double* result,
                   int M,
                   int K,
                   int N,
                   int repeats,
                   int verbose);

void dgemm_C_blas(double* matrix_a,
                  double* matrix_b,
                  double* result,
                  int M,
                  int K,
                  int N,
                  int repeats,
                  int verbose);

void dgemm_C_fallback(double* matrix_a,
                      double* matrix_b,
                      double* result,
                      int M,
                      int K,
                      int N,
                      int repeats,
                      int verbose);

void dgemm_C_loops_avx2(double* aligned_a,
                        double* aligned_b,
                        double* aligned_c,
                        int M,
                        int K,
                        int N,
                        int repeats,
                        int threads,
                        int verbose,
                        int parallelization);

void dgemm_C_loops_avx512(double* aligned_a,
                          double* aligned_b,
                          double* aligned_c,
                          int M,
                          int K,
                          int N,
                          int repeats,
                          int threads,
                          int verbose,
                          int parallelization);

int check_cuda_support(int verbose);

void sgemm_cuda_loops(double* matrix_a,
                      double* matrix_b,
                      double* result,
                      int M,
                      int K,
                      int N,
                      int repeats,
                      int verbose);

void dgemm_cuda_loops(double* matrix_a,
                      double* matrix_b,
                      double* result,
                      int M,
                      int K,
                      int N,
                      int repeats,
                      int verbose);

void sgemm_cuda_cublas(double* matrix_a,
                       double* matrix_b,
                       double* result,
                       int M,
                       int K,
                       int N,
                       int repeats,
                       int verbose);

void dgemm_cuda_cublas(double* matrix_a,
                       double* matrix_b,
                       double* result,
                       int M,
                       int K,
                       int N,
                       int repeats,
                       int verbose);
}  // namespace dgemm

#endif