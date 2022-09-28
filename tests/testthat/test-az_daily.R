test_that("all stations return data", {
  skip_if_offline()
  skip_if_not(ping_service())
  expect_equal(nrow(az_daily()), 28) #this seems to be inconsistent.  Not all stations reporting every day?  Not all at the same time?
})

test_that("numeric station_ids work", {
  skip_if_offline()
  skip_if_not(ping_service())
  expect_s3_class(az_daily(station_id = 9), "data.frame")
  expect_s3_class(az_daily(station_id = 12), "data.frame")
})

test_that("start_date works as expected", {
  skip_if_offline()
  skip_if_not(ping_service())
  start <- lubridate::now() - lubridate::weeks(1)
  expect_equal(
    az_daily(station_id = 1, start_date = format(start, "%Y-%m-%d")) |>
      nrow(),
    7
  )
})


test_that("works with station_id as a vector", {
  expect_s3_class(az_daily(station_id = c(1, 2)), "data.frame")
  res <- az_daily(station_id = c(1, 2))
  expect_equal(unique(res$meta_station_id), c("az01", "az02"))
  expect_s3_class(az_daily(station_id = c("az01", "az02")), "data.frame")
})
