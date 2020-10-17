#' Cross Join
#'
#' The `CROSS JOIN` returns all combinations of `x` and `y`, i.e. the dataset which is the number of rows in the first
#' dataset multiplied by the number of rows in the second dataset. This kind of result is called the Cartesian Product.
#'
#' @details
#' From Spark 2.1 the prerequisite for using a cross join is that, `spark.sql.crossJoin.enabled` must be set to `true`,
#' otherwise an exception will be thrown. Cartesian products are very slow. More importantly, they could consume a lot
#' of memory and trigger an OOM. If the join type is not `Inner`, Spark SQL could use a Broadcast Nested Loop Join even
#' if both sides of tables are not small enough. Thus, it also could cause lots of unwanted network traffic.
#'
#' @param x,y A pair of `data.frame`s, `data.frame` extensions (e.g. a `tibble`), or lazy `data.frame`s (e.g. from
#' {dbplyr} or {dtplyr}).
#' @param copy `logical(1)`. If `x` and `y` are not from the same data source, and `copy` is `TRUE`, then `y` will be
#' copied into the same src as `x`. This allows you to join tables across srcs, but it is a potentially expensive
#' operation so you must opt into it.
#' @param suffix `character(2)`. If there are non-joined duplicate variables in `x` and `y`, these suffixes will be
#' added to the output to disambiguate them.
#' @param ... Other parameters passed onto methods.
#' @param na_matches Should `NA` and `NaN` values match one another?
#'
#' The default, `"na"`, treats two `NA` or `NaN` values as equal, like `%in%`, [match()], [merge()].
#'
#' Use `"never"` to always treat two `NA` or `NaN` values as different, like joins for database sources, similarly to
#' `merge(incomparables = FALSE)`.
#'
#' @examples
#' x <- data.frame(
#'   id = c("id1", "id2", "id3", "id4", "id5"),
#'   val = c(2, 7, 11, 13, 17),
#'   stringsAsFactors = FALSE
#' )
#' cross_join(x, x)
#'
#' @importFrom dplyr full_join
#' @name cross_join
NULL

#' @rdname cross_join
#' @export
cross_join <- function(x, y, copy = FALSE, suffix = c(".x", ".y"), ..., na_matches = c("never", "na")) {
  UseMethod("cross_join")
}

#' @rdname cross_join
#' @export
cross_join.tbl_lazy <- function(x, y, copy = FALSE, suffix = c(".x", ".y"), ..., na_matches = c("never", "na")) {
  dplyr::full_join(x = x, y = y, by = character(), copy = copy, suffix = suffix, ..., na_matches = na_matches) # nocov
}

#' @rdname cross_join
#' @export
cross_join.data.frame <- function(x, y, copy = FALSE, suffix = c(".x", ".y"), ..., na_matches = c("na", "never")) {
  dplyr::full_join(x = x, y = y, by = character(), copy = copy, suffix = suffix, ..., na_matches = na_matches)
}
