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
#' These functions offer the benefit over the scoped variants of being able to explicitly specify the parameters for
#' each expression to evaluate.
#'
#' @param .data A Spark `DataFrame` or a `data.frame`. The data to mutate or summarise.
#' @param groups `character(n)`. The columns to group by.
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
#' A Spark `DataFrame` or a `data.frame` depending on the input, `.data`.
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
  dots <- dotdotdot(...)
  if (".by_group" %in% names(dots)) {
    warning("`.by_group = TRUE` is set by default.")
    dots[[".by_group"]] <- NULL
  }
  do.call(
    do_grouped_op,
    c(list(.data = .data), .groups = .groups, .fn = dplyr::arrange, dots, .by_group = TRUE)
  )
}

# -- helpers -------------------------------------------------------------------

#' Perform a group by operation on a Spark `DataFrame` or a `data.frame`/`tibble`.
#'
#' @return
#' The resulting `DataFrame`/`data.frame`/`tibble`, ungrouped.
#'
#' @noRd
do_grouped_op <- function(.data, .groups, .fn, ...) {
  dots <- dotdotdot(...)
  .data <- dplyr::group_by(.data, !!!rlang::syms(.groups))
  dplyr::ungroup(do.call(.fn, c(list(.data = .data), dots)))
}
