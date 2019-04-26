#ifndef DGEMM_H
#define DGEMM_H

#include <x86intrin.h>  // used for AVX instrinsics and _mm_alloc(), __mm_free()
#include <cstdio>       // for printf
#include <cstdlib>      // for size_t type
#include <cstring>      // used for memset

#define INDEX_COL(i, j, rows, cols) ((i) + ((j) * (rows)))
#define INDEX_ROW(i, j, rows, cols) ((j) + ((i) * (cols)))

#ifdef COLUMN_MAJOR
#define INDEX(i, j, rows, cols) INDEX_COL(i, j, rows, cols)
#else  // ROW_MAJOR
#define INDEX(i, j, rows, cols) INDEX_ROW(i, j, rows, cols)
#endif

// need to support mingw or old compilers which dont yet support aligned_alloc
#define ALIGNED_ALLOC(alignment, size) _mm_malloc((size), (alignment))
#define ALIGNED_FREE(ptr) _mm_free((ptr))

// include multithreading, since apple does not support OpenMP, a parallel
// library using C++11 threads is used as alternative
#if defined _OPENMP
#include <omp.h>
#endif
#include "Parallel.h"

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

enum avxTypes { fallback, avx2, avx512 };
enum mtTypes { none, openmp, stdThreads };

void dgemm_C_loops(double* matrix_a,
                   double* matrix_b,
                   double* result,
                   int M,
                   int K,
                   int N,
                   int repeats);

void dgemm_C_blas(double* matrix_a,
                  double* matrix_b,
                  double* result,
                  int M,
                  int K,
                  int N,
                  int repeats);

void dgemm_C_loops_avx(double* matrix_a,
                       double* matrix_b,
                       double* result,
                       int M,
                       int K,
                       int N,
                       int repeats,
                       int parallelization);

void dgemm_C_loops_avx2(double* aligned_a,
                        double* aligned_b,
                        double* aligned_c,
                        int M,
                        int K,
                        int N,
                        int repeats);

void dgemm_C_loops_avx512(double* aligned_a,
                          double* aligned_b,
                          double* aligned_c,
                          int M,
                          int K,
                          int N,
                          int repeats);
void dgemm_C_loops_avx2_omp(double* aligned_a,
                            double* aligned_b,
                            double* aligned_c,
                            int M,
                            int K,
                            int N,
                            int repeats);

void dgemm_C_loops_avx512_omp(double* aligned_a,
                              double* aligned_b,
                              double* aligned_c,
                              int M,
                              int K,
                              int N,
                              int repeats);

void dgemm_C_loops_avx2_tp(double* aligned_a,
                           double* aligned_b,
                           double* aligned_c,
                           int M,
                           int K,
                           int N,
                           int repeats);

void dgemm_C_loops_avx512_tp(double* aligned_a,
                             double* aligned_b,
                             double* aligned_c,
                             int M,
                             int K,
                             int N,
                             int repeats);
}  // namespace dgemm

#endif