#' A \code{stats::optim} like optimizer based on torch
#'
#' NOTE: Experimental
#'
#' @param params parameters to \code{fn} as a tensor
#' @param fn a function taking the \code{params} as input
#' @param method the method to be used for optimization as a string
#' @param control a control list with two slots, \code{maxiter} and \code{abstol}
#' @param ... Remaining parameters are passed to the selected method
#'
#' @return
#' A list
#'
#' @examples
#' library(torch)
#' library(torchoptim)
#' # from the R docs of stats::optim
#' fr <- function(x) {
#'   x1 <- x[1]
#'   x2 <- x[2]
#'   100 * (x2 - x1 * x1)^2 + (1 - x1)^2
#' }
#' optim_torch(
#'   torch_tensor(c(-1.2, 1), requires_grad = TRUE),
#'   fr,
#'   method = "lbfgs",
#'   control = list(maxiter = 10)
#' )
#' @export
#' @import torch
optim_torch <- function(params, fn, method,
                        control = list(), ...) {
  stopifnot(
    is.list(control), is.function(fn),
    is.character(method), length(method) == 1
  )
  method <- match.arg(method, c("adam", "adagrad", "adadelta", "sgd", "lbfgs"))
  optimizer <- do.call(paste0("optim_", method), list(params, ...))
  iterations <- control[["maxiter"]] %||% 1000
  abstol <- control[["abstol"]] %||% sqrt(.Machine$double.eps)

  converged <- FALSE
  last_val <- Inf
  step_fn <- function() {
    optimizer$zero_grad()
    obj_val <- fn(params)
    obj_val$backward()
    obj_val
  }
  for (i in seq_len(iterations)) {
    obj_val <- optimizer$step(step_fn)
    if (as.logical(torch_less_equal(torch_abs(obj_val - last_val), abstol))) {
      converged <- TRUE
      break
    }
    last_val <- obj_val
  }
  list(
    par = params,
    value = obj_val,
    converged = converged
  )
}

`%||%` <- function(lhs, rhs) {
  if (is.null(lhs)) rhs else lhs
}
