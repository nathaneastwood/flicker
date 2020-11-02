df <- data.frame(a = 1, b = 2, c = 3)

expect_equal(
  union_select(list(df, df, df)),
  data.frame(a = rep(1, 3), b = rep(2, 3), c = rep(3, 3)),
  info = "Multiple data.frames can be joined together"
)

expect_equal(
  union_select(list(df, df, df), c("a", "c")),
  data.frame(a = rep(1, 3), c = rep(3, 3)),
  info = "The user can select specific columns"
)

expect_equal(
  union_select(list(df, df, df), .all = FALSE),
  df,
  info = "Duplicate records are dropped when `.all = FALSE`"
)

expect_equal(
  union_select(list(mtcars)),
  mtcars,
  info = "Passing a single df returns the same df"
)

expect_error(
  union_select(mtcars),
  info = "`data` should be provided as a `list(n)`"
)

expect_error(
  union_select(list(mtcars), .all = 1),
  info = "`.all` should be a `logical(1)` vector"
)

# -- Spark ---------------------------------------------------------------------

if (identical(as.logical(Sys.getenv("NOT_ON_CRAN")), TRUE)) {
  invisible(suppressMessages(sc <- sparklyr::spark_connect(master = "local")))
  df <- dplyr::copy_to(sc, df, "df")

  expect_equal(
    union_select(list(df, df, df)) %>% sparklyr::sdf_dim(),
    c(3, 3),
    info = "Multiple data.frames can be joined together in Spark"
  )

  expect_equal(
    union_select(list(df, df, df), c("a", "c")) %>% sparklyr::sdf_dim(),
    c(3, 2),
    info = "The user can select specific columns in Spark"
  )

  expect_equal(
    union_select(list(df, df, df), .all = FALSE) %>% sparklyr::sdf_dim(),
    c(1, 3),
    info = "Duplicate records are dropped when `.all = FALSE` in Spark"
  )

  sparklyr::spark_disconnect_all()
}
