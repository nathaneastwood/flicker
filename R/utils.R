#' Replace `:::` to avoid R CMD NOTEs
#'
#' If we require the use of an unexported function from another package, we must access it using the triple colon
#' (`:::`) or code the original source code into our package. R CMD check will throw a NOTE at any use of the triple
#' colon and so this function is a simple replacement of that function.
#'
#' @param pkg `character(1)`. The name of the package you want to run an unexported function from
#' @param fun `character(1)`. The name of the function you want to call
#'
#' @examples
#' \dontrun{
#'   'stats' %:::% 'Pillai'
#' }
#'
#' @noRd
`%:::%` <- function(pkg, fun) {
  get(x = fun, envir = asNamespace(pkg), inherits = FALSE)
}

simulate_vars <- "dbplyr" %:::% "simulate_vars"
