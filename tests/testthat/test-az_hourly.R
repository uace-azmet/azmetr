library(lubridate)
skip_if_offline()
skip_if_not(ping_service())
skip_on_cran()


test_that("start_date_time works as expected", {
  res <- az_hourly(
    station_id = 1,
    start_date_time = "2022-09-29 09",
    end_date_time = "2022-09-29 13"
  )
  expect_equal(nrow(res), 5)
})

test_that("works with station_id as a vector", {
  res <-
    az_hourly(
      station_id = c(1, 2),
      start_date_time = "2022-09-28 12",
      end_date_time = "2022-09-28 12"
    )
  expect_s3_class(res, "data.frame")
  expect_equal(unique(res$meta_station_id), c("az01", "az02"))
})

test_that("data is in correct format", {
  res_default <-
    az_hourly(start_date_time = "2022-09-28 12", end_date_time = "2022-09-28 12")
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$precip_total, "double")
  expect_s3_class(res_default$date_datetime, "POSIXct")
})

test_that("no data is returned as 0x0 tibble", {
  res_nodata <-
    suppressWarnings(az_hourly(start_date_time = "1980-01-01 00", end_date_time = "1980-01-02 00"))
  expect_true(nrow(res_nodata) == 0)
  expect_s3_class(res_nodata, "tbl_df")
})

test_that("requests with 23:59:59 work", {
  h <-
    az_hourly(
      station_id = "az01",
      start_date_time = "2023-01-01 23:00",
      end_date_time = "2023-01-01 23:59"
    )
  expect_equal(nrow(h), 2)
})

test_that("start=NULL, end=NULL works as expected", {
  latest_hour <- floor_date(now(tzone = "America/Phoenix"), "hour")

  expect_message({
    null_null <-
      az_hourly(
        station_id = "az01"
      )
  }, glue::glue("Querying most recent hour of data"))

  expect_equal(nrow(null_null), 1)
  expect_equal(null_null$date_datetime, latest_hour)
})

test_that("end=NULL works as expected", {
  latest_hour <- floor_date(now(tzone = "America/Phoenix"), "hour")
  latest_hour_f <- format(latest_hour, "%Y-%m-%d %H:%M")
  dt_start <- latest_hour - hours(2)
  dt_start_f <- format(dt_start, "%Y-%m-%d %H:%M")

  expect_message({
    datetime_null <-
      az_hourly(
        station_id = "az01",
        start_date_time = dt_start
      )
  }, glue::glue("Querying data from {dt_start_f} through {latest_hour_f}"))
  #current hour might not be on API yet
  expect_in(seq(dt_start, latest_hour - hours(1), by = "hour"), datetime_null$date_datetime)
})

test_that("start as date only is rounded correctly", {
  latest_hour <- floor_date(now(tzone = "America/Phoenix"), "hour")
  latest_hour_f <- format(latest_hour, "%Y-%m-%d %H:%M")
  dt_start <- latest_hour - hours(2)
  start_input <- format(dt_start, "%Y-%m-%d")
  start_actual <- lubridate::floor_date(dt_start, "day") + lubridate::hours(1)

  expect_message(
    {
      date_null <-
        az_hourly(
          station_id = "az01",
          start_date_time = start_input
        )
    },
    glue::glue("Querying data from {start_input} 01:00 through {latest_hour_f}")
  )
  expect_equal(min(date_null$date_datetime), start_actual)
})

