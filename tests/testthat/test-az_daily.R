test_that("all stations return data", {
  skip_if_offline()
  skip_if_not(ping_service())
  expect_equal(nrow(az_daily()), 28)
})

test_that("numeric station_ids work", {
  skip_if_offline()
  skip_if_not(ping_service())
  expect_s3_class(az_daily(station_id = 9), "data.frame")
  expect_s3_class(az_daily(station_id = 11), "data.frame")
})

test_that("invalid station IDs error", {
  skip_if_offline()
  skip_if_not(ping_service())
  expect_error(az_daily(station_id = 200))
  expect_error(az_daily(station_id = "bz09"))
  expect_error(az_daily(station_id = "az2"))
  expect_error(az_daily(station_id = TRUE))
})

test_that("start_date works as expected", {
  skip_if_offline()
  skip_if_not(ping_service())
  expect_s3_class(az_daily(station_id = 1, start_date = "2022-09-23"), "data.frame")
  expect_s3_class(az_daily(station_id = 1, start_date = "2022/09/23"), "data.frame")
  last_week <- lubridate::now() - lubridate::weeks(1)
  expect_equal(nrow(az_daily(station_id = 1, start_date = format(last_week, "%Y-%m-%d"))), 7)
  expect_error(az_daily(station_id = 1, start_date  = "last week"), "`start_date` failed to parse")
})

test_that("start and end date combos error correctly", {
  expect_error(az_daily(1, start_date = "2022-09-23", end_date = "2022-09-21"))
  expect_error(az_daily(1, end_date = "2022-09-21"))
})

test_that("works with station_id as a vector", {
  expect_s3_class(az_daily(station_id = c(1, 2)), "data.frame")
  res <- az_daily(station_id = c(1, 2))
  expect_equal(unique(res$meta_station_id), c("az01", "az02"))
  expect_s3_class(az_daily(station_id = c("az01", "az02")), "data.frame")
})
