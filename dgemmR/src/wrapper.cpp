#include <R.h>
#include <Rdefines.h>
#include <cstdint>
#include "dgemm.h"

SEXP getElementFromRList(SEXP RList, const char* name) {
    SEXP element = R_NilValue;
    SEXP names = getAttrib(RList, R_NamesSymbol);
    for (uint32_t i = 0; i < (uint32_t)length(RList); i++) {
        if (strcmp(CHAR(STRING_ELT(names, i)), name) == 0) {
            element = VECTOR_ELT(RList, i);
            break;
        }
    }
    return element;
}

SEXP dgemm_C_loops(SEXP r_list) {
    SEXP _matrix_a = getElementFromRList(r_list, "matrix_a");
    SEXP _matrix_b = getElementFromRList(r_list, "matrix_b");

    double* matrix_a = REAL(_matrix_a);
    double* matrix_b = REAL(_matrix_b);

    int M = INTEGER(GET_DIM(_matrix_a))[0];
    int N = INTEGER(GET_DIM(_matrix_b))[1];
    int K = INTEGER(GET_DIM(_matrix_a))[1];

    SEXP _result;  // matrix with rows = norw_a and cols = N
    PROTECT(_result = allocMatrix(REALSXP, M, N));
    double* result = REAL(_result);

    int repeats = INTEGER(getElementFromRList(r_list, "repeats"))[0];

    dgemm::dgemm_C_loops(matrix_a, matrix_b, result, M, K, N, repeats);

    UNPROTECT(1);
    return _result;
}

SEXP dgemm_C_blas(SEXP r_list) {
    SEXP _matrix_a = getElementFromRList(r_list, "matrix_a");
    SEXP _matrix_b = getElementFromRList(r_list, "matrix_b");

    double* matrix_a = REAL(_matrix_a);
    double* matrix_b = REAL(_matrix_b);

    int M = INTEGER(GET_DIM(_matrix_a))[0];
    int N = INTEGER(GET_DIM(_matrix_b))[1];
    int K = INTEGER(GET_DIM(_matrix_a))[1];

    SEXP _result;  // matrix with rows = norw_a and cols = N
    PROTECT(_result = allocMatrix(REALSXP, M, N));
    double* result = REAL(_result);

    int repeats = INTEGER(getElementFromRList(r_list, "repeats"))[0];

    dgemm::dgemm_C_blas(matrix_a, matrix_b, result, M, K, N, repeats);

    UNPROTECT(1);
    return _result;
}

SEXP dgemm_C_loops_avx(SEXP r_list) {
    SEXP _matrix_a = getElementFromRList(r_list, "matrix_a");
    SEXP _matrix_b = getElementFromRList(r_list, "matrix_b");

    double* matrix_a = REAL(_matrix_a);
    double* matrix_b = REAL(_matrix_b);

    int M = INTEGER(GET_DIM(_matrix_a))[0];
    int N = INTEGER(GET_DIM(_matrix_b))[1];
    int K = INTEGER(GET_DIM(_matrix_a))[1];

    SEXP _result;  // matrix with rows = norw_a and cols = N
    PROTECT(_result = allocMatrix(REALSXP, M, N));
    double* result = REAL(_result);

    int repeats = INTEGER(getElementFromRList(r_list, "repeats"))[0];

    dgemm::dgemm_C_loops_avx(matrix_a, matrix_b, result, M, K, N, repeats,
                             dgemm::mtTypes::none);

    UNPROTECT(1);
    return _result;
}

SEXP dgemm_C_loops_avx_omp(SEXP r_list) {
    SEXP _matrix_a = getElementFromRList(r_list, "matrix_a");
    SEXP _matrix_b = getElementFromRList(r_list, "matrix_b");

    double* matrix_a = REAL(_matrix_a);
    double* matrix_b = REAL(_matrix_b);

    int M = INTEGER(GET_DIM(_matrix_a))[0];
    int N = INTEGER(GET_DIM(_matrix_b))[1];
    int K = INTEGER(GET_DIM(_matrix_a))[1];

    SEXP _result;  // matrix with rows = norw_a and cols = N
    PROTECT(_result = allocMatrix(REALSXP, M, N));
    double* result = REAL(_result);

    int repeats = INTEGER(getElementFromRList(r_list, "repeats"))[0];

    dgemm::dgemm_C_loops_avx(matrix_a, matrix_b, result, M, K, N, repeats,
                             dgemm::mtTypes::openmp);

    UNPROTECT(1);
    return _result;
}

SEXP dgemm_C_loops_avx_tp(SEXP r_list) {
    SEXP _matrix_a = getElementFromRList(r_list, "matrix_a");
    SEXP _matrix_b = getElementFromRList(r_list, "matrix_b");

    double* matrix_a = REAL(_matrix_a);
    double* matrix_b = REAL(_matrix_b);

    int M = INTEGER(GET_DIM(_matrix_a))[0];
    int N = INTEGER(GET_DIM(_matrix_b))[1];
    int K = INTEGER(GET_DIM(_matrix_a))[1];

    SEXP _result;  // matrix with rows = norw_a and cols = N
    PROTECT(_result = allocMatrix(REALSXP, M, N));
    double* result = REAL(_result);

    int repeats = INTEGER(getElementFromRList(r_list, "repeats"))[0];

    dgemm::dgemm_C_loops_avx(matrix_a, matrix_b, result, M, K, N, repeats,
                             dgemm::mtTypes::stdThreads);

    UNPROTECT(1);
    return _result;
}

extern "C" {
static const R_CallMethodDef callMethods[] = {
    {"_dgemm_C_loops", (DL_FUNC)&dgemm_C_loops, 1},
    {"_dgemm_C_blas", (DL_FUNC)&dgemm_C_blas, 1},
    {"_dgemm_C_loops_avx", (DL_FUNC)&dgemm_C_loops_avx, 1},
    {"_dgemm_C_loops_avx_omp", (DL_FUNC)&dgemm_C_loops_avx_omp, 1},
    {"_dgemm_C_loops_avx_tp", (DL_FUNC)&dgemm_C_loops_avx_tp, 1},
    {NULL, NULL, 0}};

void R_init_dgemmR(DllInfo* info) {
    R_registerRoutines(info, NULL, callMethods, NULL, NULL);
    R_useDynamicSymbols(info, TRUE);
}
}
