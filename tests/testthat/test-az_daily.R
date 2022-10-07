
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
  start <- "2022-09-01"
  end <- "2022-09-07"
  vcr::use_cassette("daily_start", {
    res_start <- az_daily(station_id = 1, start_date = start, end_date = end)
  })
  expect_equal(nrow(res_start), 7)
})


test_that("works with station_id as a vector", {
  skip_if_offline()
  skip_if_not(ping_service())
  vcr::use_cassette("daily_station_vector", {
    res_2 <- az_daily(station_id = c(1, 2))
  })
  expect_equal(unique(res_2$meta_station_id), c("az01", "az02"))
  expect_s3_class(res_2, "data.frame")
})

test_that("data is in correct format", {
  skip_if_offline()
  skip_if_not(ping_service())
  vcr::use_cassette("daily_default", {
    res_default <- az_daily()
  })
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$precip_total_mm, "double")
  expect_s3_class(res_default$datetime, "Date")
})
