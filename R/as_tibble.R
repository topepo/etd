#' Convert an event time vector to a tibble
#'
#' The reverse of [event_time()]: split an `event_time` vector into its `time`,
#' `status`, and `time_max` components.
#'
#' @param x An `event_time` vector.
#' @param ... Not currently used.
#'
#' @return A tibble with columns `time`, `status`, and `time_max`. `time_max` is
#'   always included and is missing for values that are not interval censored.
#'
#' @examplesIf rlang::is_installed("tibble")
#' x <- event_time(c(7, 5, 2), c("e", "r", "i"), c(NA, NA, 4))
#' tibble::as_tibble(x)
#' @exportS3Method tibble::as_tibble
as_tibble.event_time <- function(x, ...) {
  check_dots_empty()
  tibble::tibble(
    time = event_time_lower(x),
    status = field(x, "status"),
    time_max = event_time_upper(x)
  )
}
