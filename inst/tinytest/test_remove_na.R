expect_equal(
  nrow(remove_na(airquality, starts_with("O"))),
  116,
  info = "data.frame: Can use tidyselect semantics"
)

expect_equal(
  nrow(remove_na(airquality, Ozone)),
  116,
  info = "data.frame: Can pass single variables"
)

expect_equal(
  nrow(remove_na(airquality, Ozone, Solar.R)),
  111,
  info = "data.frame: Can pass multiple variables"
)

expect_equal(
  nrow(remove_na(airquality)),
  111,
  info = "data.frame: Passing no column names removes all NAs"
)

vars <- "Ozone"
expect_equal(
  nrow(remove_na(airquality, all_of(vars))),
  116,
  info = "data.frame: Can pass variable names via all_of()/any_of()"
)

expect_error(
  remove_na(airquality, tmp = Ozone),
  info = "data.frame: Can't use named inputs"
)

expect_error(
  remove_na(airquality, Ozone * 2),
  info = "data.frame: Can't use arithmetic operator `*` in selection context."
)

# -- Spark ---------------------------------------------------------------------

if (identical(as.logical(Sys.getenv("NOT_ON_CRAN")), TRUE)) {
  invisible(suppressMessages(sc <- sparklyr::spark_connect(master = "local")))
  airquality_spark <- dplyr::copy_to(sc, airquality, "airquality")

  expect_equal(
    sparklyr::sdf_nrow(remove_na(airquality_spark, starts_with("O"))),
    116,
    info = "data.frame: Can use tidyselect semantics"
  )

  expect_equal(
    sparklyr::sdf_nrow(remove_na(airquality_spark, Ozone)),
    116,
    info = "data.frame: Can pass single variables"
  )

  expect_equal(
    sparklyr::sdf_nrow(remove_na(airquality_spark, Ozone, Solar_R)),
    111,
    info = "data.frame: Can pass multiple variables"
  )

  expect_equal(
    sparklyr::sdf_nrow(remove_na(airquality_spark)),
    111,
    info = "data.frame: Passing no column names removes all NAs"
  )

  vars <- "Ozone"
  expect_equal(
    sparklyr::sdf_nrow(remove_na(airquality_spark, all_of(vars))),
    116,
    info = "data.frame: Can pass variable names via all_of()/any_of()"
  )

  expect_error(
    remove_na(airquality_spark, tmp = Ozone),
    info = "data.frame: Can't use named inputs"
  )

  expect_error(
    remove_na(airquality_spark, Ozone * 2),
    info = "data.frame: Can't use arithmetic operator `*` in selection context."
  )
}
