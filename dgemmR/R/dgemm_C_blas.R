#' Description of the dgemm_C_blas function
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
#' c <- dgemm_C_blas(a, b)
#' @useDynLib dgemmR, .registration = TRUE
#' @export
dgemm_C_blas <- function(matrix_a, matrix_b, repeats = 1) {
    to_C <- list()
    to_C$matrix_a <- matrix_a
    to_C$matrix_b <- matrix_b
    to_C$repeats <- as.integer(repeats)

    result <- .Call("_dgemm_C_blas", to_C, PACKAGE = "dgemmR")

    return(result)
}
