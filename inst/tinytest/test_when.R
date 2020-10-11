expect_equal(
  mtcars %>% mutate_when("cyl" %in% colnames(mtcars) ~ mpg * 2),
  {
    res <- mtcars
    res[, "mpg * 2"] <- res$mpg * 2
    rownames(res) <- NULL
    res
  },
  info = "Expressions are evaluated"
)

expect_equal(
  mtcars %>% mutate_when("cyl" %in% colnames(mtcars) ~ c(mpg2 = mpg * 2)),
  {
    res <- mtcars
    res[, "mpg2"] <- res$mpg * 2
    rownames(res) <- NULL
    res
  },
  info = "Column names can be defined"
)

expect_equal(
  mtcars %>% mutate_when("cyl" %in% colnames(mtcars) ~ c(mpg = mpg * 2)),
  {
    res <- mtcars
    res[, "mpg"] <- res$mpg * 2
    rownames(res) <- NULL
    res
  },
  info = "Existing columns can be overwritten"
)

expect_equal(
  mtcars %>% mutate_when("cyl" %in% colnames(mtcars) ~ c(mpg2 = mpg * 2, mpg4 = mpg2 * 2)),
  {
    res <- mtcars
    res[, "mpg2"] <- res$mpg * 2
    res[, "mpg4"] <- res$mpg * 4
    rownames(res) <- NULL
    res
  },
  info = "Multiple expressions can be passed"
)

expect_equal(
  mtcars %>% filter_when("cyl" %in% colnames(mtcars) ~ cyl == 4),
  mtcars[mtcars$cyl == 4, ],
  info = "Unnamed expressions get evaluated"
)

expect_equal(
  mtcars %>% filter_when("cyl" %in% colnames(mtcars) ~ c(cyl == 4, am == 1)),
  mtcars[mtcars$cyl == 4 & mtcars$am == 1, ],
  info = "Multiple unnamed expressions get evaluated"
)

expect_equal(
  mtcars %>% select_when("cyl" %in% colnames(mtcars) ~ c(Cylinders = cyl, everything())),
  {
    res <- mtcars[, c(2, 1, 3:ncol(mtcars))]
    colnames(res)[1] <- "Cylinders"
    res
  },
  info = "Additional arguments are passed to .fn"
)

# -- Spark ---------------------------------------------------------------------

if (identical(as.logical(Sys.getenv("NOT_ON_CRAN")), TRUE)) {
  invisible(suppressMessages(sc <- sparklyr::spark_connect(master = "local")))
  mtcars <- dplyr::copy_to(sc, mtcars, "mtcars")

  expect_equal(
    mtcars %>% filter_when("cyl" %in% colnames(mtcars) ~ cyl == 4) %>% sparklyr::sdf_nrow(),
    11L,
    info = "Filters work for Spark"
  )

  expect_equal(
    mtcars %>% mutate_when("cyl" %in% colnames(mtcars) ~ mpg * 2) %>% colnames(),
    c("mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb", "mpg * 2"),
    info = "Unnamed expressions work for Spark"
  )

  expect_equal(
    mtcars %>% select_when("cyl" %in% colnames(mtcars) ~ c(Cylinders = cyl, everything())) %>% colnames(),
    c("Cylinders", "mpg", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb"),
    info = "Additional arguments are passed to .fn"
  )

  sparklyr::spark_disconnect_all()
}
