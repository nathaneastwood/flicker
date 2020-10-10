#' Grouped Calculations
#'
#' * `mutate_groups()`: Group the data, `.data`, using [dplyr::group_by()] then apply `calculations` using
#'   [dplyr::mutate()].
#' * `summarise_groups()`: Group the data, `.data`, using [dplyr::group_by()] then summarise it by applying a
#'   `calculations` using [dplyr::summarise()].
#'
#' These functions offer the benefit over the scoped variants of being able to explicitly specify the parameters for
#' each expression to evaluate.
#'
#' @param .data A Spark `DataFrame` or a `data.frame`. The data to mutate or summarise.
#' @param groups `character(n)`. The columns to group by.
#' @param calculations `formula()` or a `list()` of `formula()`s. The calculations to apply where the LHS of the formula
#' is the name of the new column to create and the RHS is the calculation to apply.
#'
#' @examples
#' mtcars %>%
#'   mutate_groups(
#'     groups = c("am", "cyl"),
#'     calculations = avgMpg ~ mean(mpg)
#'   )
#' mtcars %>%
#'   summarise_groups(
#'     groups = c("am", "cyl"),
#'     calculations = avgMpg ~ mean(mpg)
#'   )
#'
#' # You can pass lists of formulas
#' mtcars %>%
#'   mutate_groups(
#'     groups = c("am", "cyl"),
#'     calculations = list(
#'       avgMpg ~ mean(mpg, na.rm = TRUE),
#'       avgDisp ~ mean(disp, na.rm = TRUE)
#'     )
#'   )
#'
#' @return
#' A Spark `DataFrame` or a `data.frame` depending on the input, `.data`.
#'
#' @name grouped_calculations
NULL

#' @rdname grouped_calculations
#' @export
mutate_groups <- function(.data, groups, calculations) {
  do_grouped_op(.data, groups, calculations, dplyr::mutate)
}

#' @rdname grouped_calculations
#' @export
summarise_groups <- function(.data, groups, calculations) {
  do_grouped_op(.data, groups, calculations, dplyr::summarise)
}

# -- helpers -------------------------------------------------------------------

#' Perform a group by operation on a Spark `DataFrame` or a `data.frame`/`tibble`.
#'
#' @return
#' The resulting `DataFrame`/`data.frame`/`tibble`, ungrouped.
#'
#' @noRd
do_grouped_op <- function(.data, groups, calculations, fn) {
  .data <- dplyr::group_by(.data, !!!rlang::syms(groups))
  dplyr::ungroup(do.call(fn, c(list(.data = .data), parse_formulas(calculations))))
}

#' Extract the parts of the formulas. Ensure the columns will have names.
#'
#' @return
#' A list containing two elements:
#'
#' * `lhs`: The names of the new columns to create
#' * `rhs`: The calculations to perform.
#'
#' @noRd
parse_formulas <- function(calculations) {
  if (!is.list(calculations)) calculations <- list(calculations)
  rhs <- lapply(calculations, rlang::f_rhs)
  lhs <- lapply(calculations, function(x) as.character(rlang::f_lhs(x)))
  if (any(lengths(lhs) == 0L)) {
    pos <- rlang::exec(unlist, lapply(lhs, function(x) length(x) == 0L))
    lhs[pos] <- lapply(rhs[pos], deparse)
  }
  rlang::set_names(rhs, lhs)
}
