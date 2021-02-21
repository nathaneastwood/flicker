#' Lazy R Object Checks
#'
#' @param x Any R object.
#'
#' @return A `logical(1)`.
#'
#' @export
is.tbl_lazy <- function(x) {
  inherits(x = x, what = "tbl_lazy")
}

#' @rdname is.tbl_lazy
#' @export
is.tbl_spark <- function(x) {
  inherits(x = x, what = "tbl_spark")
}
