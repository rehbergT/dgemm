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

sum(abs(c0 - c1))
sum(abs(c0 - c2))

repeats <- 3
r <- microbenchmark(
    dgemm(a, b, repeats = repeats, algo = "r_blas"),
    dgemm(a, b, repeats = repeats, algo = "r_loops"),
    dgemm(a, b, repeats = repeats, algo = "loops"),
    unit = "ms", times = 10
)
summary(r)
