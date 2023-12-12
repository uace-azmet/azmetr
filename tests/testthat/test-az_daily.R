skip_if_offline()
skip_if_not(ping_service())
skip_on_cran()

test_that("numeric station_ids work", {
  res_station <- az_daily(station_id = 9)
  expect_s3_class(res_station, "data.frame")
})

test_that("start_date works as expected", {
  start <- "2022-09-01"
  end <- "2022-09-07"
  expect_message(
    res_start <- az_daily(station_id = 1, start_date = start, end_date = end),
    "Querying data from 2022-09-01 through 2022-09-07"
  )

  expect_equal(nrow(res_start), 7)

})


test_that("works with station_id as a vector", {
  res_2 <- az_daily(station_id = c(1, 2))

  expect_equal(unique(res_2$meta_station_id), c("az01", "az02"))
  expect_s3_class(res_2, "data.frame")
})

test_that("data is in correct format", {
  res_default <- az_daily()

  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$precip_total_mm, "double")
  expect_s3_class(res_default$datetime, "Date")
})


test_that("NAs converted correctly", {
  res_missing <- az_daily(station_id = 27, start_date = "2022-09-29", end_date = "2022-09-29")
  expect_true(is.na(res_missing$eto_pen_mon_in))
  expect_true(is.na(res_missing$heat_units_13C))
  expect_true(is.na(res_missing$relative_humidity_mean))
})

test_that("no data is returned as 0x0 tibble", {
  suppressWarnings(
    res_nodata <-
      az_daily(start_date = "1980-01-01", end_date = "1980-01-02")
  )
  expect_true(nrow(res_nodata) == 0)
  expect_s3_class(res_nodata, "tbl_df")
})

test_that("warn when some data missing", {
  expect_warning(
    az_daily(station_id = "az43", start_date = "2023-01-01", end_date = "2023-07-23")
  )
})



test_that("start=NULL, end=NULL works correctly", {
  last_date <- lubridate::today(tzone = "America/Phoenix") - 1
  date_start <- last_date - 2
  expect_message(
    null_null <- az_daily(station_id = "az01"),
    glue::glue("Querying data from {last_date}")
  )
  expect_message(
    null_null <- az_daily(station_id = "az01"),
    glue::glue("Returning data from {last_date}")
  )
  expect_equal(null_null$datetime, last_date)
})

test_that("end=NULL works correctly", {
  last_date <- lubridate::today(tzone = "America/Phoenix") - 1
  date_start <- last_date - 2
  expect_message(
    date_null <- az_daily(station_id = "az01", start_date = date_start),
    glue::glue("Querying data from {date_start} through {last_date}")
  )
  expect_message(
    date_null <- az_daily(station_id = "az01", start_date = date_start),
    glue::glue("Returning data from {date_start} through {last_date}")
  )
  expect_equal(date_null$datetime, seq(date_start, last_date, by = "day"))
})

test_that("start=NULL works correctly", {
  last_date <- lubridate::today(tzone = "America/Phoenix") - 1
  expect_error(az_daily(end = last_date), "If you supply `end_date`, you must also supply `start_date`")
})

