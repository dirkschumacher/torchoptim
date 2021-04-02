
<!-- README.md is generated from README.Rmd. Please edit that file -->

# torchoptim

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of `torchoptim` is to experiment with building a `stats::optim`
like function powered by the `torch` optimizers.

Experimental, just for fun and does not support constraint optimization.
If this is a good idea remains to be seen :)

## Installation

``` r
remotes::install_github("dirkschumacher/torchoptim")
```

## Example

As an example we optimize the Rosenbrock function and compare it to the
solution from `stats::optim`.

``` r
library(torch)
library(torchoptim)

# from the R docs of stats::optim
fr <- function(x) {   ## Rosenbrock Banana function
    x1 <- x[1]
    x2 <- x[2]
    100 * (x2 - x1 * x1)^2 + (1 - x1)^2
}
grr <- function(x) { ## Gradient of 'fr'
    x1 <- x[1]
    x2 <- x[2]
    c(-400 * x1 * (x2 - x1 * x1) - 2 * (1 - x1),
       200 *      (x2 - x1 * x1))
}
# first with stats::optim
stats::optim(c(-1.2,1), fr, grr, method = "L-BFGS-B")
#> $par
#> [1] 0.9999997 0.9999995
#> 
#> $value
#> [1] 2.267577e-13
#> 
#> $counts
#> function gradient 
#>       47       47 
#> 
#> $convergence
#> [1] 0
#> 
#> $message
#> [1] "CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH"
```

And then with torch:

``` r
optim_torch(
 torch_tensor(c(-1.2, 1), requires_grad = TRUE),
 fr,
 method = "lbfgs",
 control = list(maxiter = 10)
)
#> $par
#> torch_tensor
#>  1.0000
#>  1.0000
#> [ CPUFloatType{2} ]
#> 
#> $value
#> torch_tensor
#> 1e-13 *
#>  3.6948
#> [ CPUFloatType{1} ]
#> 
#> $converged
#> [1] TRUE
```

Why is this cool you ask? We can optimize a function using lbfgs, but
without having to manually figure out it’s gradient and we can also
optimize the function on cuda.
