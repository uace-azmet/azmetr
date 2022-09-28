library(lubridate)
dt <-
  lubridate::now() |>
  floor_date("hour") |>
  format("%Y-%m-%d %H")

test_that("all stations return data", {
  skip_if_offline()
  skip_if_not(ping_service())
  expect_equal(
    az_hourly(start_date_time = dt, end_date_time = dt) |>
      nrow(),
    28
  )
})


test_that("start_date_time works as expected", {
  skip_if_offline()
  skip_if_not(ping_service())
  end <- floor_date(now(), "hour")
  start <- end - lubridate::hours(4)
  expect_equal(
    az_hourly(
      station_id = 1,
      start_date_time = format(start, "%Y/%m/%d %H"),
      end_date_time = format(end, "%Y/%m/%d %H")
    ) |> nrow(),
    5
  )
})


test_that("works with station_id as a vector", {
  expect_s3_class(az_hourly(station_id = c(1, 2)), "data.frame")
  res <- az_hourly(station_id = c(1, 2), start_date_time = dt, end_date_time = dt)
  expect_equal(unique(res$meta_station_id), c("az01", "az02"))
  expect_s3_class(
    az_hourly(
      station_id = c("az01", "az02"),
      start_date_time = dt,
      end_date_time = dt
    ),
    "data.frame"
  )
})
