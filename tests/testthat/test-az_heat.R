vcr::use_cassette("heat_default", {
  res_default <- az_heat()
})
test_that("az_heat() works", {
  expect_s3_class(res_default, "data.frame")
  expect_equal(nrow(res_default), 29) #this seems to be inconsistent.  Not all stations reporting every day?  Not all at the same time?
})

test_that("numeric station_ids work", {
  skip_if_offline()
  skip_if_not(ping_service())
  vcr::use_cassette("heat_station", {
    res_station <- az_heat(station_id = 9)
  })
  expect_s3_class(res_station, "data.frame")
})

test_that("start_date works as expected", {
  skip_if_offline()
  skip_if_not(ping_service())
  start <- "2022-09-20"
  end <- "2022-09-27"
  vcr::use_cassette("heat_start", {
    res_start <- az_heat(station_id = 1, start_date = start, end_date = end)
  })
  expect_equal(nrow(res_start), 7)
})


test_that("works with station_id as a vector", {
  vcr::use_cassette("heat_station_vector", {
    res_2 <- az_heat(station_id = c(1, 2))
  })
  expect_equal(unique(res_2$meta_station_id), c("az01", "az02"))
  expect_s3_class(res_2, "data.frame")
})

test_that("data is in correct format", {
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$eto_pen_mon_in, "double")
  expect_s3_class(res_default$datetime_last, "Date")
})
