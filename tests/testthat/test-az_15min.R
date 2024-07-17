library(lubridate)
skip_if_offline()
skip_if_not(ping_service())
skip_on_cran()

test_that("start_date_time works as expected", {
  res <- suppressWarnings(
    az_15min(
      station_id = 1,
      start_date_time = paste0(lubridate::today(tzone = "America/Phoenix"), " 02"),
      end_date_time = paste0(lubridate::today(tzone = "America/Phoenix"), " 03")
    )
  )
  expect_equal(nrow(res), 4)
})

test_that("works with station_id as a vector", {
  res <-
    suppressWarnings(
      az_15min(
        station_id = c(1, 2),
        start_date_time = paste0(lubridate::today(tzone = "America/Phoenix"), " 02"),
        end_date_time = paste0(lubridate::today(tzone = "America/Phoenix"), " 03")
      )
    )
  expect_s3_class(res, "data.frame")
  expect_equal(unique(res$meta_station_id), c("az01", "az02"))
})

test_that("data is in correct format", {
  res_default <-
    suppressWarnings(
      az_15min(
        start_date_time = paste0(lubridate::today(tzone = "America/Phoenix"), " 02"),
        end_date_time = paste0(lubridate::today(tzone = "America/Phoenix"), " 03")
      )
    )
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$precip_total_mm, "double")
  expect_s3_class(res_default$datetime, "POSIXct")
})

test_that("no data is returned as 0x0 tibble", {
  skip("not sure how to reproduce this now that request for historical data error")
  res_nodata <-
    suppressWarnings(
      az_15min(start_date_time = "1980-01-01 00", end_date_time = "1980-01-02 00")
    )
  expect_true(nrow(res_nodata) == 0)
  expect_s3_class(res_nodata, "tbl_df")
})

test_that("requests with 23:59:59 work", {
  h <-
    suppressWarnings(
      az_15min(
        station_id = "az01",
        start_date_time = paste0(lubridate::today(tzone = "America/Phoenix") - 1, " 23:00"),
        end_date_time = paste0(lubridate::today(tzone = "America/Phoenix") - 1, " 23:59")
      )
    )
  expect_equal(nrow(h), 4)
})

test_that("start=NULL, end=NULL works as expected", {
  expect_message({
    null_null <-
      suppressWarnings(
        az_15min(
          station_id = "az01"
        )
      )
  }, glue::glue("Querying most recent datetime of 15-minute data ..."))
  expect_equal(nrow(null_null), 1)
})

test_that("end=NULL works as expected", {
  dt_start <- lubridate::now(tzone = "America/Phoenix") - lubridate::minutes(15)
  end_null <-
    suppressWarnings(
      az_15min(
        station_id = "az02",
        start_date_time = dt_start
      )
    )
  expect_equal(nrow(end_null), 1)
})

test_that("start as date only is rounded correctly", {
  start_input <- lubridate::ymd(lubridate::today(tzone = "America/Phoenix"))
  end_hour <- paste0(lubridate::today(tzone = "America/Phoenix"), " 01:00:00")
  start_ymd <-
    suppressWarnings(
      az_15min(
        station_id = "az01",
        start_date_time = start_input,
        end_date_time = end_hour
      )
    )
  expect_equal(nrow(start_ymd), 4)
})
