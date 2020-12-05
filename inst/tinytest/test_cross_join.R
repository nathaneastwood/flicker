x <- data.frame(
  id = c("id1", "id2", "id3", "id4", "id5"),
  val = c(2, 7, 11, 13, 17),
  stringsAsFactors = FALSE
)

expect_equal(
  cross_join(x, x),
  data.frame(
    id_x = c(
      "id1", "id1", "id1", "id1", "id1", "id2", "id2", "id2", "id2", "id2", "id3", "id3", "id3", "id3", "id3", "id4",
      "id4", "id4", "id4", "id4", "id5", "id5", "id5", "id5", "id5"
    ),
    val_x = c(2, 2, 2, 2, 2, 7, 7, 7, 7, 7, 11, 11, 11, 11, 11, 13, 13, 13, 13, 13, 17, 17, 17, 17, 17),
    id_y = c(
      "id1", "id2", "id3", "id4", "id5", "id1", "id2", "id3", "id4", "id5", "id1", "id2", "id3", "id4", "id5", "id1", "id2", "id3", "id4", "id5", "id1", "id2", "id3", "id4", "id5"
    ),
    val_y = c(2, 7, 11, 13, 17, 2, 7, 11, 13, 17, 2, 7, 11, 13, 17, 2, 7, 11, 13, 17, 2, 7, 11, 13, 17),
    stringsAsFactors = FALSE
  ),
  info = "cross_joins for `data.frame`s work"
)

# -- Spark ---------------------------------------------------------------------

if (identical(as.logical(Sys.getenv("NOT_ON_CRAN")), TRUE)) {
  invisible(suppressMessages(sc <- sparklyr::spark_connect(master = "local")))
  x <- dplyr::copy_to(sc, x, "x")
  res <- cross_join(x, x)
  expect_equal(sparklyr::sdf_dim(res), c(25, 4), info = "cross_join() works for Spark DataFrames")
  rm(res)
  sparklyr::spark_disconnect_all()
}
