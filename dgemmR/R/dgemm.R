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
#'
#' @return returns the matrixproduct of a and b
#'
#' @examples
#' set.seed(1)
#' a <- matrix(rnorm(20), nrow = 4, ncol = 5)
#' b <- matrix(rnorm(15), nrow = 5, ncol = 3)
#' c <- dgemm(a, b)
#' @export
dgemm <- function(matrix_a, matrix_b, repeats = 1, algo = "r_blas", verbose = FALSE) {
    if (algo == "r_loops") {
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
    } else if (algo == "r_blas") {
        if (verbose) print("Using R-Blas")
        result <- NULL
        for (r in 1:repeats) {
            result <- matrix_a %*% matrix_b
        }
    }
    return(result)
}
