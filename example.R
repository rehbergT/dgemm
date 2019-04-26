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

c1 <- dgemm_R_blas(a, b)
c2 <- dgemm_R_loops(a, b)
c3 <- dgemm_C_loops(a, b)
c4 <- dgemm_C_blas(a, b)
c5 <- dgemm_C_loops_avx(a, b)
c6 <- dgemm_C_loops_avx_omp(a, b)
c7 <- dgemm_C_loops_avx_tp(a, b)
# c8 <- sgemm_cuda_loops(a, b)
# c9 <- dgemm_cuda_loops(a, b)
# c10 <- sgemm_cuda_cublas(a, b)
# c11 <- dgemm_cuda_cublas(a, b)

sum(abs(c1 - c2))
sum(abs(c1 - c3))
sum(abs(c1 - c4))
sum(abs(c1 - c5))
sum(abs(c1 - c6))
sum(abs(c1 - c7))
# sum(abs(c1 - c8))
# sum(abs(c1 - c9))
# sum(abs(c1 - c10))
# sum(abs(c1 - c11))

repeats <- 10
microbenchmark(
    dgemm_R_blas(a, b, repeats),
    dgemm_R_loops(a, b, repeats),
    dgemm_C_loops(a, b, repeats),
    dgemm_C_blas(a, b, repeats),
    dgemm_C_loops_avx(a, b, repeats),
    dgemm_C_loops_avx_omp(a, b, repeats),
    dgemm_C_loops_avx_tp(a, b, repeats),
    # sgemm_cuda_loops(a, b, repeats),
    # dgemm_cuda_loops(a, b, repeats),
    # sgemm_cuda_cublas(a, b, repeats),
    # dgemm_cuda_cublas(a, b, repeats),
    unit = "ms", times = 20
)
