#' Remove NAs
#'
#' A helper function to remove any rows where `NA` values appear in the specified column(s).
#'
#' @param .data A `tbl_spark` or a `data.frame`.
#' @param ... `symbols`. The column(s) from which `NA`s should be removed. If no columns are provided, all `NA`s will be
#' removed.
#' @param .verbose `logical(1)`. If `TRUE`, return a message recording the number of rows removed and the number of
#' rows remaining (default: `FALSE`).
#'
#' @examples
#' # You can remove NAs from a single column
#' remove_na(airquality, Ozone)
#'
#' # Or from multiple columns
#' remove_na(airquality, Ozone, Solar.R)
#'
#' # By default, the function will remove any rows where NA values
#' # appear in any column
#' remove_na(airquality)
#'
#' @return
#' An object of the same type as `.data`. The output has the following properties:
#' * Rows are a subset of the input, but appear in the same order.
#' * Columns are not modified.
#' * The number of groups will be the same.
#' * Attributes are preserved.
#'
#' @export
remove_na <- function(.data, ..., .verbose = FALSE) {
  check_not_named(...)
  UseMethod(generic = "remove_na", object = .data)
}

#' @importFrom sparklyr sdf_nrow
#' @export
remove_na.tbl_lazy <- function(.data, ..., .verbose = FALSE) {
  columns <- names(tidyselect::eval_select(rlang::expr(c(...)), data = simulate_vars(.data)))
  if (length(columns) == 0L) columns <- colnames(.data)
  columns <- rlang::syms(columns)
  out <- filter_na(.data = .data, columns = columns)
  if (isTRUE(.verbose)) filter_report(data = .data, out = out)
  out
}

#' @export
remove_na.data.frame <- function(.data, ..., .verbose = FALSE) {
  columns <- names(tidyselect::eval_select(rlang::expr(c(...)), data = .data))
  if (length(columns) == 0L) columns <- colnames(.data)
  columns <- rlang::syms(columns)
  out <- filter_na(.data = .data, columns = columns)
  if (isTRUE(.verbose)) filter_report(data = .data, out = out)
  out
}

# -- Helpers -------------------------------------------------------------------

#' @importFrom rlang enquos syms
#' @importFrom dplyr filter
#' @noRd
filter_na <- function(.data, columns) {
  columns <- lapply(columns, function(x) bquote(!is.na(.(x))))
  dplyr::filter(.data = .data, !!!columns)
}

#' Check whether any inputs are named
#' @importFrom rlang abort
#' @importFrom glue glue
#' @noRd
check_not_named <- function(...) {
  cols <- rlang::quos(...)
  for (i in which(rlang::have_name(cols))) {
    rlang::abort(c(
      x = glue::glue("Problem with `remove_na()` input `..{i}`."),
      i = glue::glue("Input `..{i}` is named."),
      i = glue::glue("Did you mean to call `mutate()` first?")
    ))
  }
}

filter_report <- function(data, out) {
  UseMethod(generic = "filter_report", object = data)
}

filter_report.default <- function(data, out) {
  warning(sprintf("`.verbose` is not supported for %s", paste(class(data), collapse = "/")))
}

filter_report.data.frame <- function(data, out) {
  n_rows <- nrow(data)
  new_n_rows <- nrow(out)
  message(sprintf("%s rows were removed. %s rows remain.", n_rows - new_n_rows, new_n_rows))
}

filter_report.tbl_spark <- function(data, out) {
  n_rows <- sparklyr::sdf_nrow(data)
  new_n_rows <- sparklyr::sdf_nrow(out)
  message(sprintf("%s rows were removed. %s rows remain.", n_rows - new_n_rows, new_n_rows))
}
