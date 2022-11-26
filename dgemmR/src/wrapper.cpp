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

SEXP dgemm_wrapper(SEXP r_list) {
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
    int algo = INTEGER(getElementFromRList(r_list, "algo"))[0];
    int verbose = INTEGER(getElementFromRList(r_list, "verbose"))[0];

    dgemm::dgemm_C(matrix_a, matrix_b, result, M, K, N, repeats, algo, verbose);

    UNPROTECT(1);
    return _result;
}

extern "C" {
static const R_CallMethodDef callMethods[] = {
    {"_dgemm_C", (DL_FUNC)&dgemm_wrapper, 1},
    {NULL, NULL, 0}};

void R_init_dgemmR(DllInfo* info) {
    R_registerRoutines(info, NULL, callMethods, NULL, NULL);
    R_useDynamicSymbols(info, TRUE);
}
}
