context("Testing dgemm_R_blas and dgemm_R_loops for equality")

test_that("dgemm_R_blas equals dgemm_R_loops", {
    set.seed(1)
    M <- 40
    N <- 50
    K <- 50

    a <- matrix(rnorm(K * M), nrow = M, ncol = K)
    b <- matrix(rnorm(K * N), nrow = K, ncol = N)

    c1 <- dgemm_R_blas(a, b)
    c2 <- dgemm_R_loops(a, b)

    expect_equal(c1, c2, tolerance = 1e-10)
})