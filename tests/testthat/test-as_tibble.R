test_that("as_tibble() reverses event_time()", {
  skip_if_not_installed("tibble")
  time <- c(7, 5, 3, 2, NA)
  status <- c("e", "r", "l", "i", NA)
  time_max <- c(NA, NA, NA, 4, NA)
  res <- tibble::as_tibble(event_time(time, status, time_max))
  expect_s3_class(res, "tbl_df")
  expect_named(res, c("time", "status", "time_max"))
  expect_identical(res$time, time)
  expect_identical(res$status, status)
  expect_identical(res$time_max, time_max)
  expect_identical(
    vctrs::field(event_time(res$time, res$status, res$time_max), "time"),
    vctrs::field(event_time(time, status, time_max), "time")
  )
})

test_that("as_tibble() always includes time_max", {
  skip_if_not_installed("tibble")
  res <- tibble::as_tibble(event_time(c(7, 5), c("e", "r")))
  expect_named(res, c("time", "status", "time_max"))
  expect_identical(res$time_max, c(NA_real_, NA_real_))

  res <- tibble::as_tibble(event_time(double(), character()))
  expect_named(res, c("time", "status", "time_max"))
  expect_identical(nrow(res), 0L)
})
