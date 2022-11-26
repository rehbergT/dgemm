context("Testing dgemm algos for equality")

test_that("dgemm returns equal resualts", {
    set.seed(1)
    M <- 40
    N <- 50
    K <- 50

    a <- matrix(rnorm(K * M), nrow = M, ncol = K)
    b <- matrix(rnorm(K * N), nrow = K, ncol = N)

    r_blas <- dgemm(a, b, algo = "r_blas")
    automatic <- dgemm(a, b, algo = "automatic")
    fallback <- dgemm(a, b, algo = "fallback")
    loops <- dgemm(a, b, algo = "loops")
    blas <- dgemm(a, b, algo = "blas")
    avx2 <- dgemm(a, b, algo = "avx2")
    avx2_omp <- dgemm(a, b, algo = "avx2_omp")
    avx2_tp <- dgemm(a, b, algo = "avx2_tp")
    avx512 <- dgemm(a, b, algo = "avx512")
    avx512_omp <- dgemm(a, b, algo = "avx512_omp")
    avx512_tp <- dgemm(a, b, algo = "avx512_tp")
    cuda_cubas_s <- dgemm(a, b, algo = "cuda_cublas_s")
    cuda_cubas_d <- dgemm(a, b, algo = "cuda_cublas_d")
    cuda_loops_s <- dgemm(a, b, algo = "cuda_loops_s")
    cuda_loops_d <- dgemm(a, b, algo = "cuda_loops_d")
    r_loops <- dgemm(a, b, algo = "r_loops")

    expect_equal(r_blas, automatic, tolerance = 1e-10)
    expect_equal(r_blas, fallback, tolerance = 1e-10)
    expect_equal(r_blas, loops, tolerance = 1e-10)
    expect_equal(r_blas, blas, tolerance = 1e-10)
    expect_equal(r_blas, avx2, tolerance = 1e-10)
    expect_equal(r_blas, avx2_omp, tolerance = 1e-10)
    expect_equal(r_blas, avx2_tp, tolerance = 1e-10)
    expect_equal(r_blas, avx512, tolerance = 1e-10)
    expect_equal(r_blas, avx512_omp, tolerance = 1e-10)
    expect_equal(r_blas, avx512_tp, tolerance = 1e-10)
    expect_equal(r_blas, cuda_cubas_s, tolerance = 1e-1) # cuda single precision
    expect_equal(r_blas, cuda_cubas_d, tolerance = 1e-10)
    expect_equal(r_blas, cuda_loops_s, tolerance = 1e-1) # cuda single precision
    expect_equal(r_blas, cuda_loops_d, tolerance = 1e-10)
    expect_equal(r_blas, r_loops, tolerance = 1e-10)
})
