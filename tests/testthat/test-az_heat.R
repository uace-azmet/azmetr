test_that("numeric station_ids work", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("heat_station", {
    res_station <- az_heat(station_id = 9)
  })
  expect_s3_class(res_station, "data.frame")
})

test_that("az_heat() returns only one row per station even with dates", {
  skip_if_offline()
  skip_if_not(ping_service())
  start <- "2022-09-20"
  end <- "2022-09-27"
  with_mock_dir("heat_start", {
    res_start <- az_heat(station_id = 1, start_date = start, end_date = end)
  })
  expect_equal(nrow(res_start), 1)
})

test_that("start and end dates interpreted correctly", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("heat_start_end", {
    res <- az_heat(station_id = 1, start_date = "2023-10-10", end_date = "2023-10-30")
  })
  expect_equal(res$datetime_last, lubridate::ymd("2023-10-30"))


  skip("not sure of desired behavior")
  expect_error(az_heat(station_id = 1, end_date = "2022-09-01"), "`end_date` is before `start_date`!")
})

test_that("end_date can be specified without start_date", {
  skip_if_offline()
  skip_if_not(ping_service())
  yesterday <- lubridate::today() - lubridate::days(1)
  with_mock_dir("heat_end", {
    res_end_old <- az_heat(station_id = 1, end_date = "2022-09-27")
    res_end_yesterday <- az_heat(station_id = 2, end_date = yesterday)
  })
  expect_s3_class(res_end_old, "data.frame")
  expect_equal(res_end_old$datetime_last, lubridate::ymd("2022-09-27"))
  expect_equal(res_end_yesterday$datetime_last, yesterday)
})

test_that("works with station_id as a vector", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("heat_station_vector", {
    res_2 <- az_heat(station_id = c(1, 2))
  })
  expect_equal(unique(res_2$meta_station_id), c("az01", "az02"))
  expect_s3_class(res_2, "data.frame")
})

test_that("data is in correct format", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("heat_default", {
    res_default <- az_heat()
  })
  expect_s3_class(res_default, "data.frame")
  expect_equal(nrow(res_default), nrow(station_info))
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$eto_pen_mon_in, "double")
  expect_s3_class(res_default$datetime_last, "Date")
})

test_that("no data is returned as 0x0 tibble", {
  with_mock_dir("heat_nodata", {
    res_nodata <-
      suppressWarnings(az_heat(start_date = "2100-01-01", end_date = "2100-01-02"))
  })
  expect_true(nrow(res_nodata) == 0)
  expect_s3_class(res_nodata, "tbl_df")
})
