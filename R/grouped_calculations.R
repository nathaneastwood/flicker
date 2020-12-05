#' Grouped Calculations
#'
#' @description
#' Each of these functions first group the data using [dplyr::group_by()] and then:
#'
#' * `mutate_groups()`: Apply calculations using [dplyr::mutate()].
#' * `transmute_groups()`: Apply calculations using [dplyr::transmute()].
#' * `summarise_groups()`: Summarise the data by applying calculations using [dplyr::summarise()].
#' * `arrange_groups()`: Order the data using [dplyr::arrange()] with `.by_group = TRUE`.
#'
#' The respective output is ungrouped.
#'
#' @param .data A `tbl_spark` or a `data.frame`.
#' @param .groups `character(n)`. The columns to group by.
#' @param ... Arguments to pass onto the respective function.
#'
#' @examples
#' mtcars %>%
#'   mutate_groups(.groups = c("am", "cyl"), avgMpg = mean(mpg))
#' mtcars %>%
#'   summarise_groups(.groups = c("am", "cyl"), avgMpg = mean(mpg))
#'
#' # Additional arguments can still be passed to the dplyr functions
#' mtcars %>%
#'   mutate_groups(.groups = "am", avgMpg = mean(mpg), .before = mpg)
#'
#' @return
#' A `tbl_spark` or a `data.frame` depending on the input, `.data`.
#'
#' @name grouped_calculations
NULL

#' @rdname grouped_calculations
#' @export
mutate_groups <- function(.data, .groups, ...) {
  do_grouped_op(.data = .data, .groups = .groups, .fn = dplyr::mutate, ...)
}

#' @rdname grouped_calculations
#' @export
summarise_groups <- function(.data, .groups, ...) {
  do_grouped_op(.data = .data, .groups = .groups, .fn = dplyr::summarise, ...)
}

#' @rdname grouped_calculations
#' @export
summarize_groups <- summarise_groups

#' @rdname grouped_calculations
#' @export
transmute_groups <- function(.data, .groups, ...) {
  do_grouped_op(.data = .data, .groups = .groups, .fn = dplyr::transmute, ...)
}

#' @rdname grouped_calculations
#' @export
arrange_groups <- function(.data, .groups, ...) {
  do_grouped_op(.data = .data, .groups = .groups, .fn = dplyr::arange, ..., .by_group = TRUE)
}

# -- helpers -------------------------------------------------------------------

#' Perform a group by operation on a `tbl_spark` or a `data.frame`/`tibble`.
#'
#' @return
#' The resulting `tbl_spark`/`data.frame`/`tibble` (depending on the input), ungrouped.
#'
#' @noRd
do_grouped_op <- function(.data, .groups, .fn, ...) {
  .data <- dplyr::group_by(.data, !!!rlang::syms(.groups))
  dplyr::ungroup(x = .fn(.data = .data, ...))
}
