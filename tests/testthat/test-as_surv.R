test_that("as_surv() uses right censoring for exact and right-censored data", {
  skip_if_not_installed("survival")
  x <- event_time(c(7, 5, NA), c("e", "r", NA))
  res <- as_surv(x)
  expect_s3_class(res, "Surv")
  expect_identical(attr(res, "type"), "right")
  expect_equal(
    res,
    survival::Surv(c(7, 5, NA), c(1L, 0L, NA), type = "right")
  )
})

test_that("as_surv() uses left censoring for exact and left-censored data", {
  skip_if_not_installed("survival")
  res <- as_surv(event_time(c(7, 5), c("e", "l")))
  expect_identical(attr(res, "type"), "left")
  expect_equal(res, survival::Surv(c(7, 5), c(1L, 0L), type = "left"))
})

test_that("as_surv() uses interval censoring for mixed data", {
  skip_if_not_installed("survival")
  x <- event_time(
    c(7, 5, 3, 2, NA),
    c("e", "r", "l", "i", NA),
    c(NA, NA, NA, 4, NA)
  )
  res <- as_surv(x)
  expect_identical(attr(res, "type"), "interval")
  expect_equal(
    res,
    survival::Surv(
      c(7, 5, 3, 2, NA),
      c(7, 5, 3, 4, NA),
      c(1L, 0L, 2L, 3L, NA),
      type = "interval"
    )
  )

  res <- as_surv(event_time(c(7, 5), c("l", "r")))
  expect_identical(attr(res, "type"), "interval")
})

test_that("as_surv() handles empty vectors", {
  skip_if_not_installed("survival")
  res <- as_surv(event_time(double(), character()))
  expect_s3_class(res, "Surv")
  expect_identical(nrow(res), 0L)
})

test_that("as_surv() errors for unsupported inputs", {
  skip_if_not_installed("survival")
  x <- event_time(1, "e")
  expect_snapshot(error = TRUE, {
    as_surv(1)
    as_surv(x, 2)
  })
})
