#!/usr/bin/env bash

cp cpp/dgemm.h dgemmR/src
cp cpp/dgemm_cuda.cu dgemmR/src
sed -i -e '1,20d' example.R
sed -i -e 's/\# //g' example.R

cat << 'EOF' > dgemmR/src/Makevars
CXX_STD = CXX11

PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS) -DCOLUMN_MAJOR
NVCC_FLAGS = -x cu -Xcompiler "-fPIC" -arch=sm_61 -I$(R_INC)
CUDA_HOME = /usr/local/cuda
CUDA_INC = $(CUDA_HOME)/include
PKG_LIBS = $(SHLIB_OPENMP_CXXFLAGS) $(BLAS_LIBS) $(FLIBS) -L$(CUDA_HOME)/lib64 -Wl,-rpath,$(CUDA_HOME)/lib64 -lcudart -lcublas ## for linking with the BLAS lib used by R

### Detect normal cpp file, avx2/avx512 cpp files and cuda files
cpp_sources = $(wildcard *.cpp)
avx2_sources = $(wildcard *avx2.cpp)
avx512_sources = $(wildcard *avx512.cpp)
cu_sources = $(wildcard *.cu)

### avx sources are also in cpp_sources -> filter them
cpp_sources := $(filter-out $(avx2_sources),$(cpp_sources))
cpp_sources := $(filter-out $(avx512_sources),$(cpp_sources))

### create variables for the specific objects
cpp_objects := $(patsubst %.cpp, %.o, $(cpp_sources))
avx2_objects := $(patsubst %.cpp, %.o, $(avx2_sources))
avx512_objects := $(patsubst %.cpp, %.o, $(avx512_sources))
cu_objects := $(patsubst %.cu, %.o, $(cu_sources))

OBJECTS = $(cpp_objects) $(avx2_objects) $(avx512_objects) $(cu_objects)

all: dgemmR.so
dgemmR.so: $(OBJECTS)

$(avx2_objects): $(avx2_sources)
	$(CXX) $(ALL_CPPFLAGS) $(ALL_CXXFLAGS) -mavx2 -mfma -c $< -o $@

$(avx512_objects): $(avx512_sources)
	$(CXX) $(ALL_CPPFLAGS) $(ALL_CXXFLAGS) -mavx512f -c $< -o $@

$(cu_objects): $(cu_sources)
	nvcc -DCOLUMN_MAJOR $(NVCC_FLAGS) -I$(CUDA_INC) -c $< -o $@

EOF

cat << 'EOL' > wrapper_insert_temp
SEXP sgemm_cuda_loops(SEXP r_list) {
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

    dgemm::sgemm_cuda_loops(matrix_a, matrix_b, result, M, K, N, repeats);

    UNPROTECT(1);
    return _result;
}

SEXP dgemm_cuda_loops(SEXP r_list) {
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

    dgemm::dgemm_cuda_loops(matrix_a, matrix_b, result, M, K, N, repeats);

    UNPROTECT(1);
    return _result;
}

SEXP sgemm_cuda_cublas(SEXP r_list) {
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

    dgemm::sgemm_cuda_cublas(matrix_a, matrix_b, result, M, K, N, repeats);

    UNPROTECT(1);
    return _result;
}

SEXP dgemm_cuda_cublas(SEXP r_list) {
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

    dgemm::dgemm_cuda_cublas(matrix_a, matrix_b, result, M, K, N, repeats);

    UNPROTECT(1);
    return _result;
}

extern "C" {
EOL

sed -i -e '/extern "C" {/r wrapper_insert_temp' dgemmR/src/wrapper.cpp
sed -i -e '136d' dgemmR/src/wrapper.cpp


cat << 'EOL' > wrapper_insert_temp
    {"_sgemm_cuda_loops", (DL_FUNC)&sgemm_cuda_loops, 1},
    {"_dgemm_cuda_loops", (DL_FUNC)&dgemm_cuda_loops, 1},
    {"_sgemm_cuda_cublas", (DL_FUNC)&sgemm_cuda_cublas, 1},
    {"_dgemm_cuda_cublas", (DL_FUNC)&dgemm_cuda_cublas, 1},
EOL
sed -i -e '/    {"_dgemm_C_loops_avx_tp", (DL_FUNC)&dgemm_C_loops_avx_tp, 1},/r wrapper_insert_temp' dgemmR/src/wrapper.cpp
rm wrapper_insert_temp

cat << 'EOF' > dgemmR/R/dgemm_cuda_cublas.R
#' Description of the dgemm_cuda_cublas function
#'
#' This function takes two matrices a and b and performs a times b and returns
#' the result. The matrix multiplication can be repeated for benchmarking.
#'
#' @param matrix_a matrix a
#' @param matrix_b matrix b
#' @param repeats determines how often the matrix multiplcation is repeated.
#'
#' @return returns the matrixproduct of a and b
#'
#' @examples
#' set.seed(1)
#' a <- matrix(rnorm(20), nrow = 4, ncol = 5)
#' b <- matrix(rnorm(15), nrow = 5, ncol = 3)
#' c <- dgemm_cuda_cublas(a, b)
#' @useDynLib dgemmR, .registration = TRUE
#' @export
dgemm_cuda_cublas <- function(matrix_a, matrix_b, repeats = 1) {
    to_C <- list()
    to_C$matrix_a <- matrix_a
    to_C$matrix_b <- matrix_b
    to_C$repeats <- as.integer(repeats)

    result <- .Call("_dgemm_cuda_cublas", to_C, PACKAGE = "dgemmR")

    return(result)
}

EOF

cat << 'EOF' > dgemmR/R/dgemm_cuda_loops.R
#' Description of the dgemm_cuda_loops function
#'
#' This function takes two matrices a and b and performs a times b and returns
#' the result. The matrix multiplication can be repeated for benchmarking.
#'
#' @param matrix_a matrix a
#' @param matrix_b matrix b
#' @param repeats determines how often the matrix multiplcation is repeated.
#'
#' @return returns the matrixproduct of a and b
#'
#' @examples
#' set.seed(1)
#' a <- matrix(rnorm(20), nrow = 4, ncol = 5)
#' b <- matrix(rnorm(15), nrow = 5, ncol = 3)
#' c <- dgemm_cuda_loops(a, b)
#' @useDynLib dgemmR, .registration = TRUE
#' @export
dgemm_cuda_loops <- function(matrix_a, matrix_b, repeats = 1) {
    to_C <- list()
    to_C$matrix_a <- matrix_a
    to_C$matrix_b <- matrix_b
    to_C$repeats <- as.integer(repeats)

    result <- .Call("_dgemm_cuda_loops", to_C, PACKAGE = "dgemmR")

    return(result)
}

EOF

cat << 'EOF' > dgemmR/R/sgemm_cuda_cublas.R
#' Description of the sgemm_cuda_cublas function
#'
#' This function takes two matrices a and b and performs a times b and returns
#' the result. The matrix multiplication can be repeated for benchmarking.
#'
#' @param matrix_a matrix a
#' @param matrix_b matrix b
#' @param repeats determines how often the matrix multiplcation is repeated.
#'
#' @return returns the matrixproduct of a and b
#'
#' @examples
#' set.seed(1)
#' a <- matrix(rnorm(20), nrow = 4, ncol = 5)
#' b <- matrix(rnorm(15), nrow = 5, ncol = 3)
#' c <- sgemm_cuda_cublas(a, b)
#' @useDynLib dgemmR, .registration = TRUE
#' @export
sgemm_cuda_cublas <- function(matrix_a, matrix_b, repeats = 1) {
    to_C <- list()
    to_C$matrix_a <- matrix_a
    to_C$matrix_b <- matrix_b
    to_C$repeats <- as.integer(repeats)

    result <- .Call("_dgemm_cuda_cublas", to_C, PACKAGE = "dgemmR")

    return(result)
}

EOF

cat << 'EOF' > dgemmR/R/sgemm_cuda_loops.R
#' Description of the sgemm_cuda_loops function
#'
#' This function takes two matrices a and b and performs a times b and returns
#' the result. The matrix multiplication can be repeated for benchmarking.
#'
#' @param matrix_a matrix a
#' @param matrix_b matrix b
#' @param repeats determines how often the matrix multiplcation is repeated.
#'
#' @return returns the matrixproduct of a and b
#'
#' @examples
#' set.seed(1)
#' a <- matrix(rnorm(20), nrow = 4, ncol = 5)
#' b <- matrix(rnorm(15), nrow = 5, ncol = 3)
#' c <- sgemm_cuda_loops(a, b)
#' @useDynLib dgemmR, .registration = TRUE
#' @export
sgemm_cuda_loops <- function(matrix_a, matrix_b, repeats = 1) {
    to_C <- list()
    to_C$matrix_a <- matrix_a
    to_C$matrix_b <- matrix_b
    to_C$repeats <- as.integer(repeats)

    result <- .Call("_sgemm_cuda_loops", to_C, PACKAGE = "dgemmR")

    return(result)
}

EOF

cat << 'EOF' > dgemmR/tests/testthat/test_checkForEquality7.R
context("Testing dgemm_R_blas and sgemm_cuda_loops for equality")

test_that("dgemm_R_blas equals sgemm_cuda_loops", {
    set.seed(1)
    M <- 40
    N <- 50
    K <- 50

    a <- matrix(rnorm(K * M), nrow = M, ncol = K)
    b <- matrix(rnorm(K * N), nrow = K, ncol = N)

    c1 <- dgemm_R_blas(a, b)
    c2 <- sgemm_cuda_loops(a, b)

    expect_equal(c1, c2, tolerance = 0.1)
})
EOF

cat << 'EOF' > dgemmR/tests/testthat/test_checkForEquality8.R
context("Testing dgemm_R_blas and dgemm_cuda_loops for equality")

test_that("dgemm_R_blas equals dgemm_cuda_loops", {
    set.seed(1)
    M <- 40
    N <- 50
    K <- 50

    a <- matrix(rnorm(K * M), nrow = M, ncol = K)
    b <- matrix(rnorm(K * N), nrow = K, ncol = N)

    c1 <- dgemm_R_blas(a, b)
    c2 <- dgemm_cuda_loops(a, b)

    expect_equal(c1, c2, tolerance = 1e-10)
})
EOF

cat << 'EOF' > dgemmR/tests/testthat/test_checkForEquality9.R
context("Testing dgemm_R_blas and sgemm_cuda_cublas for equality")

test_that("dgemm_R_blas equals sgemm_cuda_cublas", {
    set.seed(1)
    M <- 40
    N <- 50
    K <- 50

    a <- matrix(rnorm(K * M), nrow = M, ncol = K)
    b <- matrix(rnorm(K * N), nrow = K, ncol = N)

    c1 <- dgemm_R_blas(a, b)
    c2 <- sgemm_cuda_cublas(a, b)

    expect_equal(c1, c2, tolerance = 0.1)
})
EOF

cat << 'EOF' > dgemmR/tests/testthat/test_checkForEquality10.R
context("Testing dgemm_R_blas and dgemm_cuda_cublas for equality")

test_that("dgemm_R_blas equals dgemm_cuda_cublas", {
    set.seed(1)
    M <- 40
    N <- 50
    K <- 50

    a <- matrix(rnorm(K * M), nrow = M, ncol = K)
    b <- matrix(rnorm(K * N), nrow = K, ncol = N)

    c1 <- dgemm_R_blas(a, b)
    c2 <- dgemm_cuda_cublas(a, b)

    expect_equal(c1, c2, tolerance = 1e-10)
})
EOF