#' Description of the dgemm_R_blas function
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
#' c <- dgemm_R_blas(a, b)
#'
#' @export
dgemm_R_blas <- function(matrix_a, matrix_b, repeats = 1) {

    result <- NULL
    for (r in 1:repeats) {
        result <- matrix_a %*% matrix_b
    }

    return(result)
}
