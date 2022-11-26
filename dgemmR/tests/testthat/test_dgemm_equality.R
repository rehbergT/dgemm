context("Testing dgemm algos for equality")

test_that("dgemm returns equal resualts", {
    set.seed(1)
    M <- 40
    N <- 50
    K <- 50

    a <- matrix(rnorm(K * M), nrow = M, ncol = K)
    b <- matrix(rnorm(K * N), nrow = K, ncol = N)

    r_blas <- dgemm(a, b, algo = "r_blas")
    r_loops <- dgemm(a, b, algo = "r_loops")

    expect_equal(r_blas, r_loops, tolerance = 1e-10)
})
