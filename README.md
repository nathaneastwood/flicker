<!-- README.md is generated from README.Rmd. Please edit that file -->

{sparkplugs} <a href='https://nathaneastwood.github.io/sparkplugs/'><img src='man/figures/logo.png' align="right" height="139" /></a>
=====================================================================================================================================

[![CRAN
status](https://www.r-pkg.org/badges/version/sparkplugs)](https://cran.r-project.org/package=sparkplugs)
[![Dependencies](https://tinyverse.netlify.com/badge/sparkplugs)](https://cran.r-project.org/package=sparkplugs)
![CRAN downloads](https://cranlogs.r-pkg.org/badges/sparkplugs) [![R
build
status](https://github.com/nathaneastwood/sparkplugs/workflows/R-CMD-check/badge.svg)](https://github.com/nathaneastwood/sparkplugs/actions?workflow=R-CMD-check)
[![codecov](https://codecov.io/gh/nathaneastwood/sparkplugs/branch/master/graph/badge.svg?token=4BAJ9EB25K)](https://codecov.io/gh/nathaneastwood/sparkplugs)

Overview
--------

{sparkplugs} is a collection of useful wrapper functions and extensions
to the {dplyr} API which also work with Spark.

Installation
------------

You can install:

-   the development version from
    [GitHub](https://github.com/nathaneastwood/sparkplugs) with

``` r
# install.packages("remotes")
remotes::install_github("nathaneastwood/sparkplugs")
```

-   the latest release from CRAN with

``` r
install.packages("sparkplugs")
```

Usage
-----

### Grouped Operations

These functions offer the benefit over the scoped variants of being able
to explicitly specify the parameters for each expression to evaluate.

``` r
library(sparkplugs)
mtcars %>%
  summarise_groups(
    groups = c("am", "cyl"),
    calculations = list(
      avgMpg ~ mean(mpg, na.rm = TRUE),
      avgDisp ~ mean(disp, na.rm = TRUE)
    )
  )
# # A tibble: 6 x 4
#      am   cyl avgMpg avgDisp
#   <dbl> <dbl>  <dbl>   <dbl>
# 1     0     4   22.9   136. 
# 2     0     6   19.1   205. 
# 3     0     8   15.0   358. 
# 4     1     4   28.1    93.6
# 5     1     6   20.6   155  
# 6     1     8   15.4   326
```

### Scoped Variant “when”

These functions are subtly different from the scoped `_if()` variants of
{dplyr} functions in that they can evaluate any predicate. They are
useful when used within a chain of commands.

``` r
mtcars %>% filter_when("cyl" %in% colnames(mtcars) ~ cyl == 4)
#                 mpg cyl  disp  hp drat    wt  qsec vs am gear carb
# Datsun 710     22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
# Merc 240D      24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
# Merc 230       22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
# Fiat 128       32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
# Honda Civic    30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
# Toyota Corolla 33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
# Toyota Corona  21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
# Fiat X1-9      27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
# Porsche 914-2  26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
# Lotus Europa   30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2
# Volvo 142E     21.4   4 121.0 109 4.11 2.780 18.60  1  1    4    2
```

### Union Select

This function will union the records from multiple data sets returning
only the requested columns.

``` r
a <- data.frame(col1 = 1:5, col2 = 6, col3 = rnorm(5))
b <- data.frame(col1 = 1:3, col2 = 4, col3 = rnorm(3))
c <- data.frame(col1 = c(0, 1, 1, 2, 3, 5, 8), col3 = rnorm(7))

union_select(data = list(a, b, c), cols = c("col1", "col3"))
#    col1       col3
# 1     1 -0.1652663
# 2     2  0.5642257
# 3     3 -0.2621375
# 4     4 -1.3734869
# 5     5 -0.1842106
# 6     1  1.3066999
# 7     2  0.8065603
# 8     3 -0.4230033
# 9     0 -0.2312634
# 10    1  0.4222195
# 11    1  0.2022071
# 12    2 -0.1268781
# 13    3 -0.2100050
# 14    5 -1.3496464
# 15    8  1.0153586
```

### Cross Joins

As of {dplyr} 1.0.0, cross joins have been available through the use of
`full_join(by = character())` but this is not a natural way to perform
the operation in my opinion.

``` r
x <- data.frame(id = 1:2, val = rnorm(2))
y <- data.frame(run = 1:2, res = rnorm(2))
cross_join(x, y)
#   id         val run         res
# 1  1  0.04907316   1 -0.02114536
# 2  1  0.04907316   2  1.09011219
# 3  2 -1.20422625   1 -0.02114536
# 4  2 -1.20422625   2  1.09011219
```
