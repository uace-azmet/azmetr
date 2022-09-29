test_that("all stations return data", {
  skip_if_offline()
  skip_if_not(ping_service())
  vcr::use_cassette("daily_default", {
    res <- az_daily()
  })
  expect_equal(nrow(res), 28) #this seems to be inconsistent.  Not all stations reporting every day?  Not all at the same time?
})

test_that("numeric station_ids work", {
  skip_if_offline()
  skip_if_not(ping_service())
  vcr::use_cassette("daily_station", {
    res_station <- az_daily(station_id = 9)
  })
  expect_s3_class(res_station, "data.frame")
})

test_that("start_date works as expected", {
  skip_if_offline()
  skip_if_not(ping_service())
  # start <- lubridate::now() - lubridate::weeks(1)
  start <- "2022-09-22"
  vcr::use_cassette("daily_start", {
    res_start <- az_daily(station_id = 1, start_date = start)
  })
  expect_equal(nrow(res_start), 7)
})


test_that("works with station_id as a vector", {
  expect_s3_class(az_daily(station_id = c(1, 2)), "data.frame")
  vcr::use_cassette("daily_station_vector", {
    res <- az_daily(station_id = c(1, 2))
  })
  expect_equal(unique(res$meta_station_id), c("az01", "az02"))
  expect_s3_class(az_daily(station_id = c("az01", "az02")), "data.frame")
})

#TODO: data tests (numeric? date?)
