#ifndef DGEMM_H
#define DGEMM_H

#include <immintrin.h>  // used for AVX instrinsics
#include <cstdio>       // for printf
#include <cstdlib>      // for size_t type
#include <cstring>      // used for memset

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
    avx512 = 5
};

void dgemm_C(double* matrix_a,
             double* matrix_b,
             double* result,
             int M,
             int K,
             int N,
             int repeats,
             int algo,
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
                        int verbose);

void dgemm_C_loops_avx512(double* aligned_a,
                          double* aligned_b,
                          double* aligned_c,
                          int M,
                          int K,
                          int N,
                          int repeats,
                          int verbose);
}  // namespace dgemm

#endif