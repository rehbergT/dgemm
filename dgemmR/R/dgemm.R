#' Description of the dgemm_C function
#'
#' This function takes two matrices a and b and performs a times b and returns
#' the result. The matrix multiplication can be repeated for benchmarking.
#'
#' @param matrix_a matrix a
#' @param matrix_b matrix b
#' @param repeats determines how often the matrix multiplcation is repeated.
#' @param algo select algo.
#' @param verbose enable output.
#' @param threads select number of threads
#'
#' @return returns the matrixproduct of a and b
#'
#' @examples
#' set.seed(1)
#' a <- matrix(rnorm(20), nrow = 4, ncol = 5)
#' b <- matrix(rnorm(15), nrow = 5, ncol = 3)
#' c <- dgemm(a, b)
#' @useDynLib dgemmR, .registration = TRUE
#' @export
dgemm <- function(matrix_a, matrix_b, repeats = 1, algo = "blas", verbose = FALSE, threads = 8) {
    algo_int <- NULL
    if (algo == "automatic") {
        algo_int <- 0
    } else if (algo == "fallback") {
        algo_int <- 1
    } else if (algo == "loops") {
        algo_int <- 2
    } else if (algo == "blas") {
        algo_int <- 3
    } else if (algo == "avx2") {
        algo_int <- 4
    } else if (algo == "avx2_omp") {
        algo_int <- 5
    } else if (algo == "avx2_tp") {
        algo_int <- 6
    } else if (algo == "avx512") {
        algo_int <- 7
    } else if (algo == "avx512_omp") {
        algo_int <- 8
    } else if (algo == "avx512_tp") {
        algo_int <- 9
    } else if (algo == "cuda_cublas_s") {
        algo_int <- 10
    } else if (algo == "cuda_cublas_d") {
        algo_int <- 11
    } else if (algo == "cuda_loops_s") {
        algo_int <- 12
    } else if (algo == "cuda_loops_d") {
        algo_int <- 13
    } else if (algo == "r_loops") {
        algo_int <- 14
    } else if (algo == "r_blas") {
        algo_int <- 15
    } else {
        algo_int <- 1
    }


    if (algo_int < 14) {
        to_C <- list()
        to_C$matrix_a <- matrix_a
        to_C$matrix_b <- matrix_b
        to_C$repeats <- as.integer(repeats)
        to_C$algo <- as.integer(algo_int)
        to_C$verbose <- as.integer(verbose)
        to_C$threads <- as.integer(threads)

        result <- .Call("_dgemm_C", to_C, PACKAGE = "dgemmR")
    } else if (algo_int == 14) {
        if (verbose) print("Using R-loops")
        M <- nrow(matrix_a)
        N <- ncol(matrix_b)
        K <- ncol(matrix_a)

        for (r in 1:repeats) {
            result <- matrix(0, nrow = M, ncol = N)

            for (m in 1:M) {
                for (n in 1:N) {
                    sum <- 0.0
                    for (k in 1:K) {
                        sum <- sum + matrix_a[m, k] * matrix_b[k, n]
                    }

                    result[m, n] <- sum
                }
            }
        }
    } else {
        if (verbose) print("Using R-Blas")
        result <- NULL
        for (r in 1:repeats) {
            result <- matrix_a %*% matrix_b
        }
    }
    return(result)
}
