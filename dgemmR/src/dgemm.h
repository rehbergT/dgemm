#ifndef DGEMM_H
#define DGEMM_H

#include <cstdio>  // for printf

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

namespace dgemm {

void dgemm_C_loops(double* matrix_a,
                   double* matrix_b,
                   double* result,
                   int M,
                   int K,
                   int N,
                   int repeats,
                   int verbose);
}  // namespace dgemm

#endif