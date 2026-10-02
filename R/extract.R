#' Extract components of an event time vector
#'
#' `extract_time()` returns the event times and `extract_status()` returns the
#' censoring status codes.
#'
#' @param x An object.
#' @param ... Not currently used.
#'
#' @return
#' - `extract_time()`: a double vector when no values are interval censored.
#'   Otherwise, a two-column matrix with columns `time` and `time_max`, where
#'   `time_max` is missing for values that are not interval censored.
#' - `extract_status()`: a character vector of status codes (`"e"`, `"r"`,
#'   `"l"`, or `"i"`).
#'
#' @examples
#' x <- event_time(c(7, 5, 2), c("e", "r", "i"), c(NA, NA, 4))
#' extract_time(x)
#' extract_status(x)
#'
#' extract_time(x[1:2])
#' @export
extract_time <- function(x, ...) {
  UseMethod("extract_time")
}

#' @rdname extract_time
#' @export
extract_time.event_time <- function(x, ...) {
  check_dots_empty()
  time <- event_time_lower(x)
  if (!any(field(x, "status") == "i", na.rm = TRUE)) {
    return(time)
  }
  cbind(time = time, time_max = event_time_upper(x))
}

#' @rdname extract_time
#' @export
extract_status <- function(x, ...) {
  UseMethod("extract_status")
}

#' @rdname extract_time
#' @export
extract_status.event_time <- function(x, ...) {
  check_dots_empty()
  field(x, "status")
}

event_time_lower <- function(x) {
  vapply(field(x, "time"), `[`, double(1), 1)
}

# `NA` for values that are not interval censored.
event_time_upper <- function(x) {
  vapply(
    field(x, "time"),
    function(t) if (length(t) == 2) t[2] else NA_real_,
    double(1)
  )
}
