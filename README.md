<!-- README.md is generated from README.Rmd. Please edit that file -->

{flicker} <a href='https://nathaneastwood.github.io/flicker/'><img src='man/figures/logo.png' align="right" height="139" /></a>
===============================================================================================================================

[![CRAN
status](https://www.r-pkg.org/badges/version/flicker)](https://cran.r-project.org/package=flicker)
[![Dependencies](https://tinyverse.netlify.com/badge/flicker)](https://cran.r-project.org/package=flicker)
![CRAN downloads](https://cranlogs.r-pkg.org/badges/flicker) [![R build
status](https://github.com/nathaneastwood/flicker/workflows/R-CMD-check/badge.svg)](https://github.com/nathaneastwood/flicker/actions?workflow=R-CMD-check)
[![codecov](https://codecov.io/gh/nathaneastwood/flicker/branch/master/graph/badge.svg?token=4BAJ9EB25K)](https://codecov.io/gh/nathaneastwood/flicker)

Overview
--------

{flicker} is a collection of useful wrapper functions and extensions to
the {dplyr} API which also work with Spark.

Installation
------------

You can install:

-   the development version from
    [GitHub](https://github.com/nathaneastwood/flicker) with

``` r
# install.packages("remotes")
remotes::install_github("nathaneastwood/flicker")
```

-   the latest release from CRAN with

``` r
install.packages("flicker")
```

Usage
-----

### Grouped Operations

These functions offer the benefit over the scoped variants of being able
to explicitly specify the parameters for each expression to evaluate.

``` r
library(flicker)
mtcars %>%
  summarise_groups(
    .groups = c("am", "cyl"),
    avgMpg = mean(mpg, na.rm = TRUE),
    avgDisp = mean(disp, na.rm = TRUE)
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
previous_result <- 42
mtcars %>% filter_when(previous_result < 42, cyl == 4)
#                      mpg cyl  disp  hp drat    wt  qsec vs am gear carb
# Mazda RX4           21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
# Mazda RX4 Wag       21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
# Datsun 710          22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
# Hornet 4 Drive      21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
# Hornet Sportabout   18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
# Valiant             18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
# Duster 360          14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4
# Merc 240D           24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
# Merc 230            22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2
# Merc 280            19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4
# Merc 280C           17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4
# Merc 450SE          16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3
# Merc 450SL          17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3
# Merc 450SLC         15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3
# Cadillac Fleetwood  10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4
# Lincoln Continental 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4
# Chrysler Imperial   14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4
# Fiat 128            32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1
# Honda Civic         30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
# Toyota Corolla      33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1
# Toyota Corona       21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
# Dodge Challenger    15.5   8 318.0 150 2.76 3.520 16.87  0  0    3    2
# AMC Javelin         15.2   8 304.0 150 3.15 3.435 17.30  0  0    3    2
# Camaro Z28          13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4
# Pontiac Firebird    19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2
# Fiat X1-9           27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1
# Porsche 914-2       26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2
# Lotus Europa        30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2
# Ford Pantera L      15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4
# Ferrari Dino        19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6
# Maserati Bora       15.0   8 301.0 335 3.54 3.570 14.60  0  1    5    8
# Volvo 142E          21.4   4 121.0 109 4.11 2.780 18.60  1  1    4    2
mtcars %>% filter_when(previous_result >= 42, cyl == 4)
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

But we can also perform these checks as if using the scoped variants of
{dplyr} functions.

``` r
mtcars %>% filter_when("mpg" %in% colnames(.), cyl == 4)
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

union_select(.data = list(a, b, c), c("col1", "col3"))
#    col1       col3
# 1     1 -1.5936792
# 2     2  0.4583218
# 3     3 -0.7568519
# 4     4  1.3170420
# 5     5 -0.6419245
# 6     1  0.5815826
# 7     2  1.6735513
# 8     3  0.8638010
# 9     0 -1.2806895
# 10    1  0.1915506
# 11    1 -0.1021699
# 12    2 -0.9799384
# 13    3 -1.2197154
# 14    5 -0.9946515
# 15    8 -0.1872739
```

### Cross Joins

As of {dplyr} 1.0.0, cross joins have been available through the use of
`full_join(by = character())` but this is not a natural way to perform
the operation in my opinion. {flicker} provides a way to perform cross
joins for earlier versions of {dplyr}.

``` r
x <- data.frame(id = 1:2, val = rnorm(2))
y <- data.frame(run = 1:2, res = rnorm(2))
cross_join(x, y)
#   id        val run        res
# 1  1 0.17952160   1  0.2839802
# 2  1 0.17952160   2 -0.2063309
# 3  2 0.08163433   1  0.2839802
# 4  2 0.08163433   2 -0.2063309
```
