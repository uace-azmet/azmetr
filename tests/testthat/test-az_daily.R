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
})
