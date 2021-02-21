expect_false(is.tbl_lazy(mtcars), info = "is.tbl_lazy() returns FALSE when expected")
expect_false(is.tbl_spark(mtcars), info = "is.tbl_spark() returns FALSE when expected")

if (identical(as.logical(Sys.getenv("NOT_ON_CRAN")), TRUE)) {
  invisible(suppressMessages(sc <- sparklyr::spark_connect(master = "local")))
  mtcars_spark <- dplyr::copy_to(sc, mtcars, "mtcars")

  expect_true(is.tbl_lazy(mtcars_spark), info = "Check is.tbl_lazy() works.")
  expect_true(is.tbl_spark(mtcars_spark), info = "Check is.tbl_spark() works.")
}
