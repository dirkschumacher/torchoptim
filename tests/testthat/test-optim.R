test_that("adam optimizer rosenbrock", {
  # from the R docs of optim
  fr <- function(x) {
    x1 <- x[1]
    x2 <- x[2]
    100 * (x2 - x1 * x1)^2 + (1 - x1)^2
  }
  result <- optim_torch(
    torch_tensor(c(-1.2, 1), requires_grad = TRUE),
    fr,
    method = "lbfgs",
    control = list(maxiter = 10)
  )
  expect_equal(mean(abs(as.numeric(result$par))), 1, tolerance = 0.00001)
  expect_true(result$converged)
})
