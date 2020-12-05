#' Evaluate When
#'
#' Evaluate conditional expressions and if it evaluates to `TRUE`, execute the function call's logic. Note that these
#' functions are subtly different from the scoped variants of {dplyr} functions in that they can evaluate any condition.
#' If the condition evaluates to `FALSE`, these functions will return the original data.
#'
#' @param .data A `tbl_spark` or a `data.frame`.
#' @param .cond A condition that will evaluate to a `logical(1)`. When it evaluates to `TRUE`, arguments passed to
#' `...` will be evaluated in the context of `.data`.
#' @param ... Additional parameters to pass to the {dplyr} function.
#'
#' @examples
#' # Let's say we have another object and based on this object we
#' # want to perform some conditional logic
#' previous_result <- 42
#'
#' # We can evaluate expressions in the same way as the dplyr function.
#' # If the evaluation is FALSE, it will return the original data.
#' mtcars %>%
#'   mutate_when(previous_result < 42, mpg * 2)
#' # And if the condition if TRUE, it will evaluate
#' mtcars %>%
#'   mutate_when(previous_result >= 42, mpg * 2)
#'
#' # We can evaluate multiple expressions
#' mtcars %>%
#'   mutate_when(previous_result >= 42, mpg2 = mpg * 2, mpg4 = mpg * 2)
#'
#' # We can still use functionality such as tidy-select
#' mtcars %>%
#'   select_when(previous_result >= 42, Cylinders = cyl, everything())
#'
#' # We can also evaluate logic that is conditional on .data
#' mtcars %>%
#'   filter_when("mpg" %in% colnames(.), cyl == 4)
#'
#' @return
#' A `tbl_spark` or a `data.frame` depending on the input, `.data`.
#'
#' @name when
NULL

#' @rdname when
#' @export
arrange_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::arrange, ...)
}

#' @rdname when
#' @export
distinct_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::distinct, ...)
}

#' @rdname when
#' @export
filter_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::filter, ...)
}

#' @rdname when
#' @export
group_by_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::group_by, ...)
}

#' @rdname when
#' @export
mutate_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::mutate, ...)
}

#' @rdname when
#' @export
select_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::select, ...)
}

#' @rdname when
#' @export
summarise_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::summarise, ...)
}

#' @rdname when
#' @export
transmute_when <- function(.data, .cond, ...) {
  do_when(.data, .cond, dplyr::transmute, ...)
}

# -- helpers -------------------------------------------------------------------

#' @inheritParams when
#' @param .fn `language`. The function to call.
#' @noRd
do_when <- function(.data, .cond, .fn, ...) {
  if (length(.cond) > 1L) warning("Condition does not evaluate to a `logical(1)`.")
  if (.cond) .fn(.data = .data, ...) else .data
}
