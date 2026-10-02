#' Convert to a survival object
#'
#' `as_surv()` converts an object to the format produced by
#' [survival::Surv()].
#'
#' @param x An object to convert.
#' @param ... Not currently used.
#'
#' @details
#' For `event_time` vectors, the type of the result depends on the censoring
#' types present:
#'
#' - Only exact and right-censored values: `type = "right"`.
#' - Only exact and left-censored values: `type = "left"`.
#' - Any other combination: `type = "interval"`.
#'
#' Missing values in `x` are missing in the result.
#'
#' @return A `Surv` object.
#'
#' @examplesIf rlang::is_installed("survival")
#' x <- event_time(
#'   time = c(7, 5, 3, 2),
#'   status = c("e", "r", "l", "i"),
#'   time_max = c(NA, NA, NA, 4)
#' )
#' as_surv(x)
#'
#' as_surv(event_time(c(7, 5), c("e", "r")))
#'
#' if (rlang::is_installed(c("dplyr", "survival"))) {
#'   library(dplyr)
#'   library(survival)
#'
#'   set.seed(1)
#'   tibble(times = sort(rexp(5)), status = c("l", "e", "e", "e", "r")) |>
#'     mutate(
#'       event_time = event_time(times, status),
#'       surv_obj = as_surv(event_time)
#'     )
#' }
#' @export
as_surv <- function(x, ...) {
  UseMethod("as_surv")
}

#' @rdname as_surv
#' @export
as_surv.default <- function(x, ...) {
  cli::cli_abort(
    "Can't convert {.obj_type_friendly {x}} to a {.cls Surv} object."
  )
}

#' @rdname as_surv
#' @export
as_surv.event_time <- function(x, ...) {
  rlang::check_installed("survival")
  check_dots_empty()

  time <- field(x, "time")
  status <- field(x, "status")
  lower <- vapply(time, `[`, double(1), 1)
  upper <- vapply(time, function(t) t[length(t)], double(1))
  status[is.na(x)] <- NA_character_
  observed <- unique(stats::na.omit(status))

  if (length(x) == 0) {
    # `Surv()` warns for zero-length input, so build the empty object directly.
    empty <- matrix(
      double(),
      ncol = 2,
      dimnames = list(NULL, c("time", "status"))
    )
    structure(empty, type = "right", class = "Surv")
  } else if (all(observed %in% c("e", "r"))) {
    survival::Surv(lower, as.integer(status == "e"), type = "right")
  } else if (all(observed %in% c("e", "l"))) {
    survival::Surv(lower, as.integer(status == "e"), type = "left")
  } else {
    # Interval coding: 0 = right, 1 = event, 2 = left, 3 = interval censored.
    code <- unname(c(r = 0L, e = 1L, l = 2L, i = 3L)[status])
    survival::Surv(lower, upper, code, type = "interval")
  }
}
