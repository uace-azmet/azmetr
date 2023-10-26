
test_that("numeric station_ids work", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("daily_station", {
    res_station <- az_daily(station_id = 9)
  })
  expect_s3_class(res_station, "data.frame")
})

test_that("start_date works as expected", {
  skip_if_offline()
  skip_if_not(ping_service())
  start <- "2022-09-01"
  end <- "2022-09-07"
  with_mock_dir("daily_start", {
    expect_message(
      res_start <- az_daily(station_id = 1, start_date = start, end_date = end),
      "Querying data from 2022-09-01 to 2022-09-07"
    )
  })
  expect_equal(nrow(res_start), 7)

})


test_that("works with station_id as a vector", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("daily_station_vector", {
    res_2 <- az_daily(station_id = c(1, 2))
  })
  expect_equal(unique(res_2$meta_station_id), c("az01", "az02"))
  expect_s3_class(res_2, "data.frame")
})

test_that("data is in correct format", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("daily_default", {
    res_default <- az_daily()
  })
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$precip_total_mm, "double")
  expect_s3_class(res_default$datetime, "Date")
})


test_that("NAs converted correctly", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("daily_missing", {
    res_missing <- az_daily(station_id = 27, start_date = "2022-09-29", end_date = "2022-09-29")
  })
  expect_true(is.na(res_missing$eto_pen_mon_in))
  expect_true(is.na(res_missing$heat_units_13C))
  expect_true(is.na(res_missing$relative_humidity_mean))
})

test_that("no data is returned as 0x0 tibble", {
  suppressWarnings(
    with_mock_dir("daily_nodata", {
      res_nodata <-
        az_daily(start_date = "2100-01-01", end_date = "2100-01-02")
    })
  )
  expect_true(nrow(res_nodata) == 0)
  expect_s3_class(res_nodata, "tbl_df")
})

test_that("warn when some data missing", {
  expect_warning(
    with_mock_dir("daily_partial", {
      az_daily(station_id = "az43", start_date = "2023-01-01", end_date = "2023-07-23")
    })
  )
})

