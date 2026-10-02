test_that("extract_time() returns a vector without interval censoring", {
  x <- event_time(c(7, 5, NA), c("e", "r", NA))
  expect_identical(extract_time(x), c(7, 5, NA))
})

test_that("extract_time() returns a matrix with interval censoring", {
  x <- event_time(c(7, 5, 2, NA), c("e", "r", "i", NA), c(NA, NA, 4, NA))
  res <- extract_time(x)
  expect_true(is.matrix(res))
  expect_identical(colnames(res), c("time", "time_max"))
  expect_identical(res[, "time"], c(7, 5, 2, NA))
  expect_identical(res[, "time_max"], c(NA, NA, 4, NA))
})

test_that("extract_time() handles empty vectors", {
  expect_identical(extract_time(event_time(double(), character())), double())
})

test_that("extract_status() returns the status codes", {
  x <- event_time(c(7, 5, 2, NA), c("e", "r", "i", NA), c(NA, NA, 4, NA))
  expect_identical(extract_status(x), c("e", "r", "i", NA))
})

test_that("extractors error for extra arguments", {
  x <- event_time(1, "e")
  expect_snapshot(error = TRUE, {
    extract_time(x, 2)
    extract_status(x, 2)
  })
})
