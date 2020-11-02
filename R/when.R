#' Evaluate When
#'
#' Evaluate expressions against a Spark `DataFrame` (or `data.frame`) if a predicate evaluates to `TRUE`. Note that
#' these functions are subtly different from the scoped variants of dplyr functions in that they can evaluate any
#' predicate.
#'
#' @param .data A Spark `DataFrame` or a `data.frame`.
#' @param .cond A `formula()`. The LHS is the predicate condition to evaluate. When it evaluates to `TRUE`, the RHS
#'  will be performed in the context of the function. The RHS can be in one of several forms:
#'
#' * An expression, e.g. `x * y`
#' * A named expression, e.g. `c(z = x * y)`
#' * A vector or `list` of the above.
#'
#' Note: named expressions must be wrapped in `c()` or `list()`.
#' @param ... Additional parameters to pass to the dplyr function.
#'
#' @examples
#' # Unname expressions will return columns with the expression as the name
#' mtcars %>% mutate_when("cyl" %in% colnames(mtcars) ~ mpg * 2)
#'
#' # But we can name them easily enough
#' mtcars %>% mutate_when("cyl" %in% colnames(mtcars) ~ c(mpg2 = mpg * 2))
#'
#' # We can evaluate multiple expressions
#' mtcars %>%
#'   mutate_when("cyl" %in% colnames(mtcars) ~ c(mpg2 = mpg * 2, mpg4 = mpg * 2))
#'
#' # We can still use functionality such as tidy-select
#' mtcars %>%
#'   select_when("cyl" %in% colnames(mtcars) ~ c(Cylinders = cyl, everything()))
#'
#' @return
#' A Spark `DataFrame` or a `data.frame` depending on the input, `.data`.
#'
#' @name when
NULL

#' @rdname when
#' @export
arrange_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::arrange, .name = FALSE, ...)
}

#' @rdname when
#' @export
distinct_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::distinct, .name = TRUE, ...)
}

#' @rdname when
#' @export
filter_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::filter, .name = FALSE, ...)
}

#' @rdname when
#' @export
group_by_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::group_by, .name = FALSE, ...)
}

#' @rdname when
#' @export
mutate_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::mutate, .name = TRUE, ...)
}

#' @rdname when
#' @export
select_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::select, .name = TRUE, ...)
}

#' @rdname when
#' @export
summarise_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::summarise, .name = TRUE, ...)
}

#' @rdname when
#' @export
transmute_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::transmute, .name = TRUE, ...)
}

# -- helpers -------------------------------------------------------------------

#' @inheritParams when
#' @inheritParams desconstruct_rhs
#' @param .fn `language`. The function to call.
#' @noRd
do_when <- function(.data, .cond, .fn, .name = TRUE, ...) {
  lhs <- rlang::f_lhs(.cond)
  rhs <- rlang::f_rhs(.cond)
  test <- eval(lhs)
  if (!is.logical(test) || !length(test) == 1L || is.na(test)) {
    stop("`.cond` should evaluate to a `logical(1)` vector.")
  }
  if (test) do.call(.fn, c(list(.data = .data), deconstruct_rhs(rhs, .name), ...)) else .data
}

#' @param rhs `formula()`. The RHS of `.cond`.
#' @param .name `logical(1)`. Whether to name the RHS elements of the formula. This will feed into naming new columns.
#' @noRd
deconstruct_rhs <- function(rhs, .name = TRUE) {
  lst_rhs <- as.list(rhs)
  if (lst_rhs[[1]] == quote(c) || lst_rhs[[1]] == quote(list)) {
    as.list(rhs)[-1]
  } else {
    if (isTRUE(.name)) {
      rlang::set_names(list(rhs), deparse(rhs))
    } else {
      list(rhs)
    }
  }
}
