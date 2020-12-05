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
#' @param x,y A pair of `tbl_spark`s or `data.frame`s.
#' @inheritParams dbplyr::full_join.tbl_lazy
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
#' @importFrom utils packageVersion
#' @name cross_join
NULL

#' @rdname cross_join
#' @export
cross_join <- function(x, y, copy = FALSE, suffix = c("_x", "_y"), ..., na_matches = c("never", "na")) {
  UseMethod("cross_join")
}

#' @rdname cross_join
#' @export
cross_join.tbl_lazy <- function(x, y, copy = FALSE, suffix = c("_x", "_y"), ..., na_matches = c("never", "na")) {
  dplyr::full_join(x = x, y = y, by = character(), copy = copy, suffix = suffix, ..., na_matches = na_matches) # nocov
}

#' @rdname cross_join
#' @export
cross_join.data.frame <- function(x, y, copy = FALSE, suffix = c("_x", "_y"), ..., na_matches = c("na", "never")) {
  na_matches <- match.arg(na_matches, choices = c("na", "never"), several.ok = FALSE)
  if (utils::packageVersion("dplyr") < "1.0.0") { # nocov start
    warning("`na_matches` only works for {dplyr} version '1.0.0' and above.")
    common_cols <- intersect(colnames(x), colnames(y))

    if (length(common_cols) > 0L) {
      x <- dplyr::rename_at(x, common_cols, ~paste0(., suffix[1]))
      y <- dplyr::rename_at(y, common_cols, ~paste0(., suffix[2]))
    }

    x <- dplyr::mutate(x, `_const` = TRUE)
    y <- dplyr::mutate(y, `_const` = TRUE)
    res <- dplyr::inner_join(x, y, by = "_const")
    return(dplyr::select(res, -`_const`))
  } # nocov end
  dplyr::full_join(x = x, y = y, by = character(), copy = copy, suffix = suffix, ..., na_matches = na_matches)
}
