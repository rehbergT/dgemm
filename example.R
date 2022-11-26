# call roxygen2 to create the manuals from the comments above the functions
#        pkgbuild::compile_dll(); devtools::document()
#
# run devtools tests:
#        devtools::check(document = FALSE)
#
# run unit tests:
#        devtools::test()
#
# run lintr
#        lintr::lint_package()
#
# build vignette using devtools
#        devtools::build_vignettes()
#
# open a terminal, go to this folder and call the R build command:
#        R CMD build dgemmR
#
# verify the package:
#        R CMD check dgemmR_0.1.0.tar.gz
rm(list = ls())
library(microbenchmark)
devtools::clean_dll("dgemmR")
devtools::load_all("dgemmR")

set.seed(1)
M <- 40
N <- 500
K <- 52

a <- matrix(rnorm(K * M), nrow = M, ncol = K)
b <- matrix(rnorm(K * N), nrow = K, ncol = N)

c0 <- dgemm(a, b, algo = "r_blas", verbose = TRUE)
c1 <- dgemm(a, b, algo = "r_loops", verbose = TRUE)
c2 <- dgemm(a, b, algo = "loops", verbose = TRUE)
c3 <- dgemm(a, b, algo = "blas", verbose = TRUE)
c4 <- dgemm(a, b, algo = "automatic", verbose = TRUE)
c5 <- dgemm(a, b, algo = "fallback", verbose = TRUE)
c6 <- dgemm(a, b, algo = "avx2", verbose = TRUE)
c7 <- dgemm(a, b, algo = "avx2_omp", verbose = TRUE)
c8 <- dgemm(a, b, algo = "avx2_tp", verbose = TRUE)
c9 <- dgemm(a, b, algo = "avx512", verbose = TRUE)
c10 <- dgemm(a, b, algo = "avx512_omp", verbose = TRUE)
c11 <- dgemm(a, b, algo = "avx512_tp", verbose = TRUE)
c12 <- dgemm(a, b, algo = "cuda_cublas_s", verbose = TRUE)
c13 <- dgemm(a, b, algo = "cuda_cublas_d", verbose = TRUE)
c14 <- dgemm(a, b, algo = "cuda_loops_s", verbose = TRUE)
c15 <- dgemm(a, b, algo = "cuda_loops_d", verbose = TRUE)

sum(abs(c0 - c1))
sum(abs(c0 - c2))
sum(abs(c0 - c3))
sum(abs(c0 - c4))
sum(abs(c0 - c5))
sum(abs(c0 - c6))
sum(abs(c0 - c7))
sum(abs(c0 - c8))
sum(abs(c0 - c9))
sum(abs(c0 - c10))
sum(abs(c0 - c11))
sum(abs(c0 - c12))
sum(abs(c0 - c13))
sum(abs(c0 - c14))
sum(abs(c0 - c15))

repeats <- 3
r <- microbenchmark(
    dgemm(a, b, repeats = repeats, algo = "r_blas"),
    dgemm(a, b, repeats = repeats, algo = "r_loops"),
    dgemm(a, b, repeats = repeats, algo = "loops"),
    dgemm(a, b, repeats = repeats, algo = "blas"),
    dgemm(a, b, repeats = repeats, algo = "automatic"),
    dgemm(a, b, repeats = repeats, algo = "fallback"),
    dgemm(a, b, repeats = repeats, algo = "avx2"),
    dgemm(a, b, repeats = repeats, algo = "avx2_omp"),
    dgemm(a, b, repeats = repeats, algo = "avx2_tp"),
    dgemm(a, b, repeats = repeats, algo = "avx512"),
    dgemm(a, b, repeats = repeats, algo = "avx512_omp"),
    dgemm(a, b, repeats = repeats, algo = "avx512_tp"),
    dgemm(a, b, repeats = repeats, algo = "cuda_cublas_s"),
    dgemm(a, b, repeats = repeats, algo = "cuda_cublas_d"),
    dgemm(a, b, repeats = repeats, algo = "cuda_loops_s"),
    dgemm(a, b, repeats = repeats, algo = "cuda_loops_d"),
    unit = "ms", times = 10
)
summary(r)
