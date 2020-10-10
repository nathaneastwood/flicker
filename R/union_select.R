#' Union Select Columns From Multiple Datasets
#'
#' This function will union the records from multiple data sets returning only the requested columns (all of which are
#' assumed to be named the same between data sets).
#'
#' @param data A `list()` of `data.frame`s or Spark `DataFrame`s.
#' @param cols `character(n)`. The name(s) of the columns to return (def: `NULL`).
#' @param all `logical(1)`. Whether to keep duplicate records (def: `TRUE`) or not (`FALSE`).
#'
#' @return
#' A Spark `DataFrame` or a `data.frame` depending on the input, `.data`.
#'
#' @examples
#' a <- data.frame(col1 = c(1:10, 10), col2 = 6)
#' b <- data.frame(col1 = c(1:5, 5), col2 = 4)
#' c <- data.frame(col1 = c(0, 1, 1, 2, 3, 5, 8))
#'
#' # You can union specific columns
#' union_select(data = list(a, b, c), cols = "col1")
#'
#' # And you can remove duplicate records
#' union_select(data = list(a, b, c), cols = "col1", all = FALSE)
#'
#' @export
union_select <- function(data, cols = NULL, all = TRUE) {
  if (!inherits(data, "list")) stop("`data` should be provided as a `list(n)`")
  if (!is.logical(all) || length(all) != 1L) stop("`all` should be a `logical(1)` vector")
  if (!is.null(cols) && !is.character(cols)) stop("`cols` should be a `character(n)` vector")
  if (!is.null(cols)) data <- lapply(data, function(x, cols) dplyr::select(x, !!!cols), cols = cols)
  res <- data[[1]]
  if (length(data) == 1L) return(res)
  for (i in seq_along(data)[-1]) {
    res <- if (all) dplyr::union_all(res, data[[i]]) else dplyr::union(res, data[[i]])
  }
  res
}
