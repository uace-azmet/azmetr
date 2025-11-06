skip_if_offline()
skip_if_not(ping_service())
skip_on_cran()

test_that("numeric station_ids work", {
  res_station <- az_lwdaily(station_id = 9)
  expect_s3_class(res_station, "data.frame")
})

test_that("start_date works as expected", {
  start <- "2024-07-01"
  end <- "2024-07-07"
  expect_message(
    res_start <- az_lwdaily(station_id = 1, start_date = start, end_date = end),
    "Querying data from 2024-07-01 through 2024-07-07"
  )
  expect_equal(nrow(res_start), 7)
})

test_that("works with station_id as a vector", {
  res_2 <- az_lwdaily(station_id = c(1, 2))
  expect_equal(unique(res_2$meta_station_id), c("az01", "az02"))
  expect_s3_class(res_2, "data.frame")
})

test_that("data is in correct format", {
  res_default <- az_lwdaily()
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$dwpt_30cm_mean, "double")
  expect_s3_class(res_default$date, "Date")
})

test_that("NAs converted correctly", {
  res_missing <- az_lwdaily(station_id = 1, start_date = "2024-07-01", end_date = "2024-07-01")
  expect_true(is.na(res_missing$dwpt_30cm_mean))
  expect_true(is.na(res_missing$lw1_total_wet_mins))
  expect_true(is.na(res_missing$relative_humidity_30cm_min))
  expect_true(is.na(res_missing$temp_air_30cm_maxC))
})

test_that("no data is returned as 0x0 tibble", {
  skip("Not sure how to reproduce this anymore now that these dates error")
  res_nodata <-
    suppressWarnings(
      az_lwdaily(start_date = "1980-01-01", end_date = "1980-01-02")
    )
  expect_true(nrow(res_nodata) == 0)
  expect_s3_class(res_nodata, "tbl_df")
})

test_that("warn when some data missing", {
  expect_warning(
    az_lwdaily(station_id = "az14", start_date = "2024-01-01", end_date = "2024-07-15")
  )
})

test_that("start=NULL, end=NULL works correctly", {
  null_null <- az_lwdaily(station_id = 2)
  expect_equal(nrow(null_null), 1)
})

test_that("end=NULL works correctly", {
  date_start <- lubridate::today(tzone = "America/Phoenix") - 2
  last_date <- date_start + 1
  expect_message(
    date_null <- az_lwdaily(station_id = "az01", start_date = date_start),
    glue::glue("Querying data from {date_start} through {last_date} ...")
  )
  expect_message(
    date_null <- az_lwdaily(station_id = "az01", start_date = date_start),
    glue::glue("Returning data from {date_start}")
  )
  expect_equal(
    date_null$date,
    seq(date_start, last_date, by = "day"),
    ignore_attr = TRUE
  )
})

test_that("start=NULL works correctly", {
  last_date <- lubridate::today(tzone = "America/Phoenix") - 1
  expect_error(az_lwdaily(end = last_date), "If you supply `end_date`, you must also supply `start_date`")
})
