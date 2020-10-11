expect_equal(
  mtcars %>% arrange_when("cyl" %in% colnames(mtcars) ~ mpg),
  {
    res <- mtcars
    res[order(res$mpg), ]
  },
  info = "arrange expressions are evaluated"
)

expect_equal(
  mtcars %>% distinct_when("cyl" %in% colnames(mtcars) ~ am),
  data.frame(am = c(1, 0)),
  info = "distinct expressions are evaluted"
)

expect_equal(
  mtcars %>% filter_when("cyl" %in% colnames(mtcars) ~ cyl == 4),
  mtcars[mtcars$cyl == 4, ],
  info = "filter expressions are evaluated"
)

expect_equal(
  mtcars %>% group_by_when("cyl" %in% colnames(mtcars) ~ am) %>% dplyr::group_vars(),
  "am",
  info = "group_by expressions are evaluated"
)

expect_equal(
  mtcars %>% mutate_when("cyl" %in% colnames(mtcars) ~ mpg * 2),
  {
    res <- mtcars
    res[, "mpg * 2"] <- res$mpg * 2
    rownames(res) <- NULL
    res
  },
  info = "mutate expressions are evaluated"
)

expect_equal(
  mtcars %>% select_when("cyl" %in% colnames(mtcars) ~ mpg),
  mtcars[, "mpg", drop = FALSE],
  info = "select expressions are evaluated"
)

expect_equal(
  mtcars %>% summarise_when("cyl" %in% colnames(mtcars) ~ mean(mpg)),
  data.frame("mean(mpg)" = mean(mtcars$mpg), check.names = FALSE),
  info = "summarise expressions are evaluated"
)

expect_equal(
  mtcars %>% transmute_when("cyl" %in% colnames(mtcars) ~ mpg * 2),
  {
    res <- mtcars
    rownames(res) <- NULL
    res$`mpg * 2` <- res$mpg * 2
    res[, "mpg * 2", drop = FALSE]
  },
  info = "transmute expressions are evaluated"
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

expect_equal(
  mtcars %>% select_when("hello_world" %in% colnames(mtcars) ~ cyl),
  mtcars,
  info = "FALSE tests still return the input data"
)

expect_error(
  mtcars %>% select_when("hello_world" ~ cyl),
  info = "`.eval` should evaluate to a `logical(1)` vector."
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
