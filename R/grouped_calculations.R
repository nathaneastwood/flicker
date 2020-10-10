#' Grouped Calculations
#'
#' * `mutate_groups()`: Group the data, `x`, using [dplyr::group_by()] then apply `calculations` using
#'   [dplyr::mutate()].
#' * `summarise_groups()`: Group the data, `x`, using [dplyr::group_by()] then summarise it by applying a
#'   `calculations` using [dplyr::summarise()].
#'
#' @param x A Spark `DataFrame` or a `data.frame`. The data to mutate or summarise.
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
#' A Spark `DataFrame` or a `data.frame` depending on the input, `x`.
#'
#' @name grouped_calculations
NULL

#' @rdname grouped_calculations
#' @export
mutate_groups <- function(x, groups, calculations) {
  do_grouped_op(x, groups, calculations, dplyr::mutate)
}

#' @rdname grouped_calculations
#' @export
summarise_groups <- function(x, groups, calculations) {
  do_grouped_op(x, groups, calculations, dplyr::summarise)
}

#' Perform a group by operation on a Spark `DataFrame` or a `data.frame`/`tibble`.
#'
#' @return
#' The resulting `DataFrame`/`data.frame`/`tibble`, ungrouped.
#'
#' @noRd
do_grouped_op <- function(x, groups, calculations, fn) {
  x <- dplyr::group_by(x, !!!rlang::syms(groups))
  dplyr::ungroup(do.call(fn, c(list(.data = x), parse_formulas(calculations))))
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
  if (any(lengths(lhs) == 0)) {
    pos <- do.call(c, lapply(lhs, function(x) length(x) == 0L))
    lhs[pos] <- lapply(rhs[pos], deparse)
  }
  rlang::set_names(rhs, lhs)
}
