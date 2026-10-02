#' Create a vector of event times
#'
#' `event_time()` creates a vector of event times that may be exact times, or
#' right/left/interval censored.
#'
#' @param time A non-negative numeric vector (double or integer) of event times.
#'   For interval-censored values, this is the lower end of the interval.
#' @param status A character vector the same length as `time`. Possible values
#'   are `"e"` (complete/exact), `"r"` (right censored), `"l"` (left censored),
#'   and `"i"` (interval censored). It can only be missing where `time` is
#'   missing.
#' @param time_max A numeric vector the same length as `time` with the upper end
#'   of the interval for interval-censored values. It must be missing for
#'   values that are not interval censored, and greater than `time` otherwise.
#'   The default `NULL` sets all values to missing.
#' @param call The execution environment of a currently running function, used
#'   in error messages.
#'
#' @return An `event_time` vector. Each element of its `time` field is a single
#'   number, or a sorted pair of numbers for interval-censored values.
#'
#' @examples
#' x <- event_time(
#'   time = c(7, 5, 3, 2, NA),
#'   status = c("e", "r", "l", "i", NA),
#'   time_max = c(NA, NA, NA, 4, NA)
#' )
#' x
#'
#' x[2:4]
#'
#' if (rlang::is_installed(c("dplyr"))) {
#'   library(dplyr)
#'
#'   set.seed(1)
#'   tibble(times = sort(rexp(5)), status = c("l", "e", "e", "e", "r")) |>
#'     mutate(event_time = event_time(times, status))
#' }
#' @export
event_time <- function(
  time,
  status,
  time_max = NULL,
  call = rlang::current_env()
) {
  n <- length(time)
  if (is.null(time_max)) {
    time_max <- rep(NA_real_, n)
  }
  time <- vec_cast(time, double(), x_arg = "time", call = call)
  time_max <- vec_cast(time_max, double(), x_arg = "time_max", call = call)

  if (!is.character(status)) {
    cli::cli_abort(
      "{.arg status} must be a character vector, not {.obj_type_friendly {status}}.",
      call = call
    )
  }
  if (length(status) != n) {
    cli::cli_abort(
      "{.arg status} must have length {n} (the length of {.arg time}), not {length(status)}.",
      call = call
    )
  }
  if (length(time_max) != n) {
    cli::cli_abort(
      "{.arg time_max} must have length {n} (the length of {.arg time}), not {length(time_max)}.",
      call = call
    )
  }

  idx <- which(time < 0)
  if (length(idx) > 0) {
    cli::cli_abort(
      "{.arg time} must be non-negative. Problem at {cli::qty(length(idx))}location{?s} {idx}.",
      call = call
    )
  }

  idx <- which(is.na(status) & !is.na(time))
  if (length(idx) > 0) {
    cli::cli_abort(
      "{.arg status} must not be missing when {.arg time} is not missing. Problem at {cli::qty(length(idx))}location{?s} {idx}.",
      call = call
    )
  }

  idx <- which(!is.na(status) & !status %in% event_status_values)
  if (length(idx) > 0) {
    cli::cli_abort(
      c(
        "{.arg status} must be one of {.val {event_status_values}}.",
        "x" = "Problem at {cli::qty(length(idx))}location{?s} {idx}."
      ),
      call = call
    )
  }

  is_interval <- !is.na(status) & status == "i"

  idx <- which(!is_interval & !is.na(time_max))
  if (length(idx) > 0) {
    cli::cli_abort(
      "{.arg time_max} must be missing for values that are not interval censored. Problem at {cli::qty(length(idx))}location{?s} {idx}.",
      call = call
    )
  }

  idx <- which(is_interval & is.na(time_max))
  if (length(idx) > 0) {
    cli::cli_abort(
      "{.arg time_max} must not be missing for interval-censored values. Problem at {cli::qty(length(idx))}location{?s} {idx}.",
      call = call
    )
  }

  idx <- which(is_interval & time >= time_max)
  if (length(idx) > 0) {
    cli::cli_abort(
      "{.arg time} must be smaller than {.arg time_max} for interval-censored values. Problem at {cli::qty(length(idx))}location{?s} {idx}.",
      call = call
    )
  }

  pooled <- vector("list", n)
  for (i in seq_len(n)) {
    pooled[[i]] <- if (is_interval[i]) c(time[i], time_max[i]) else time[i]
  }

  new_event_time(pooled, status, call = call)
}

event_status_values <- c("e", "r", "l", "i")

#' Low-level constructor for event time vectors
#'
#' `new_event_time()` creates an `event_time` vector with only minimal type
#' checks. Use [event_time()] to create a validated vector.
#'
#' @param time A list. Each element is a single double, or a sorted pair of
#'   doubles for interval-censored values.
#' @param status A character vector of status codes.
#' @inheritParams event_time
#'
#' @return An `event_time` vector.
#'
#' @examples
#' new_event_time(list(7, c(2, 4)), c("e", "i"))
#' @export
new_event_time <- function(
  time = list(),
  status = character(),
  call = rlang::current_env()
) {
  if (!is.list(time)) {
    cli::cli_abort(
      "{.arg time} must be a list, not {.obj_type_friendly {time}}.",
      call = call
    )
  }
  if (!is.character(status)) {
    cli::cli_abort(
      "{.arg status} must be a character vector, not {.obj_type_friendly {status}}.",
      call = call
    )
  }
  new_rcrd(list(time = time, status = status), class = "event_time")
}

#' @export
is.na.event_time <- function(x) {
  vapply(field(x, "time"), anyNA, logical(1))
}

#' @export
format.event_time <- function(x, ...) {
  time <- field(x, "time")
  status <- field(x, "status")
  # Format all values jointly so they share the same number of decimal places.
  flat <- format(unlist(time), trim = TRUE, ...)
  grp <- factor(rep(seq_along(time), lengths(time)), levels = seq_along(time))
  out <- unname(vapply(split(flat, grp), paste, character(1), collapse = ", "))
  suffix <- c(e = " ", r = "+", l = "-", i = "")
  out <- paste0(out, suffix[status])
  is_interval <- !is.na(status) & status == "i"
  out[is_interval] <- paste0("[", out[is_interval], "]")
  out[is.na(x)] <- NA_character_
  out
}

#' @export
obj_print_data.event_time <- function(x, ...) {
  if (length(x) == 0) {
    return(invisible(x))
  }
  print(format(x), quote = FALSE)
  invisible(x)
}

#' @export
vec_ptype_abbr.event_time <- function(x, ...) "evtm"

#' @export
vec_ptype_full.event_time <- function(x, ...) "event_time"

#' @exportS3Method pillar::pillar_shaft
pillar_shaft.event_time <- function(x, ...) {
  time <- field(x, "time")
  status <- field(x, "status")
  # Use pillar's numeric shaft so values get the same significant digits
  # (`pillar.sigfig`) and decimal alignment as a double column.
  num_shaft <- pillar::pillar_shaft(unlist(time), ...)
  flat <- format(num_shaft, width = attr(num_shaft, "width"))
  flat <- cli::ansi_trimws(flat, which = "left")
  grp <- factor(rep(seq_along(time), lengths(time)), levels = seq_along(time))
  pieces <- split(as.character(flat), grp)
  is_interval <- !is.na(status) & status == "i"
  out <- character(length(x))
  out[!is_interval] <- unlist(pieces[!is_interval], use.names = FALSE)
  out[is_interval] <- vapply(
    pieces[is_interval],
    function(p) paste0("[", paste(cli::ansi_trimws(p), collapse = ", "), "]"),
    character(1)
  )
  # Put the suffix right after the number and the decimal-alignment padding
  # after the suffix.
  num <- cli::ansi_trimws(out[!is_interval], which = "right")
  pad <- strrep(" ", cli::ansi_nchar(out[!is_interval]) - cli::ansi_nchar(num))
  suffix <- c(e = " ", r = "+", l = "-", i = "")
  out[!is_interval] <- paste0(num, suffix[status[!is_interval]], pad)
  out[is.na(x)] <- NA_character_
  pillar::new_pillar_shaft_simple(out, align = "right")
}

#' @exportS3Method pillar::obj_sum
obj_sum.event_time <- function(x) {
  paste0(vec_ptype_abbr(x), " [", length(x), "]")
}
