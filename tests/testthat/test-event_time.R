test_that("event_time() pools time and time_max", {
  x <- event_time(
    time = c(7, 5, 3, 2, NA),
    status = c("e", "r", "l", "i", NA),
    time_max = c(NA, NA, NA, 4, NA)
  )
  expect_s3_class(x, "event_time")
  expect_length(x, 5)
  expect_identical(vctrs::field(x, "time"), list(7, 5, 3, c(2, 4), NA_real_))
  expect_identical(vctrs::field(x, "status"), c("e", "r", "l", "i", NA))
})

test_that("event_time() accepts integer time", {
  x <- event_time(1:2, c("e", "i"), c(NA, 3L))
  expect_identical(vctrs::field(x, "time"), list(1, c(2, 3)))
})

test_that("event_time() allows missing time with a status", {
  x <- event_time(c(1, NA), c("e", "r"))
  expect_identical(is.na(x), c(FALSE, TRUE))
})

test_that("event_time vectors can be subset and combined", {
  x <- event_time(c(7, 2), c("e", "i"), c(NA, 4))
  expect_identical(vctrs::field(x[2], "time"), list(c(2, 4)))
  expect_length(c(x, x), 4)
})

test_that("event_time() validates inputs", {
  expect_snapshot(error = TRUE, {
    event_time("a", "e")
    event_time(1, 1)
    event_time(1:2, "e")
    event_time(1, "e", c(NA, NA))
    event_time(c(-1, -2), c("e", "e"))
    event_time(c(1, 2, 3), c("e", NA, NA))
    event_time(1, "x")
    event_time(1, "e", 3)
    event_time(1, "i")
    event_time(c(5, 1), c("i", "i"), c(4, 3))
  })
})

test_that("event_time() errors use the supplied call", {
  wrapper <- function(t, s) event_time(t, s, call = rlang::current_env())
  expect_snapshot(error = TRUE, wrapper(1, "x"))
})

test_that("new_event_time() checks types", {
  expect_snapshot(error = TRUE, {
    new_event_time(1, "e")
    new_event_time(list(1), 1)
  })
})

test_that("event_time vectors print", {
  x <- event_time(
    time = c(7, 5, 3, 2, NA),
    status = c("e", "r", "l", "i", NA),
    time_max = c(NA, NA, NA, 4, NA)
  )
  expect_snapshot({
    x
    event_time(double(), character())
  })
})

test_that("format() aligns decimal places", {
  x <- event_time(c(0, 0.397, 2.983), c("e", "l", "r"))
  expect_identical(format(x), c("0.000 ", "0.397-", "2.983+"))
})

test_that("event_time vectors print in tibbles", {
  skip_if_not_installed("tibble")
  x <- event_time(c(7, 5, 2), c("e", "r", "i"), c(NA, NA, 4))
  expect_snapshot({
    tibble::tibble(x = x)
    tibble::tibble(x = list(x, x[1]))
  })
})

test_that("tibble columns use pillar's significant digits", {
  skip_if_not_installed("tibble")
  x <- event_time(
    c(0, 0.397, 2.983, 1.23456, NA, 2.5),
    c("e", "l", "r", "r", NA, "i"),
    c(NA, NA, NA, NA, NA, 4)
  )
  expect_snapshot({
    tibble::tibble(x = x)
    withr::with_options(list(pillar.sigfig = 5), print(tibble::tibble(x = x)))
  })
})

test_that("obj_sum() summarizes the vector", {
  x <- event_time(c(7, 5), c("e", "r"))
  expect_identical(pillar::obj_sum(x), "evtm [2]")
})
