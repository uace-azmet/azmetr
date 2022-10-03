library(lubridate)
# dt <-
#   (lubridate::now() - days(1)) |>
#   floor_date("hour") |>
#   format("%Y-%m-%d %H")
dt <- "2022-09-28 12"

test_that("all stations return data", {
  skip_if_offline()
  skip_if_not(ping_service())
  vcr::use_cassette("hourly", {
    res <- az_hourly(start_date_time = dt, end_date_time = dt)
  })
  expect_equal(nrow(res), 28)
})


test_that("start_date_time works as expected", {
  skip_if_offline()
  skip_if_not(ping_service())
  vcr::use_cassette("hourly_start", {
    res <- az_hourly(
      station_id = 1,
      start_date_time = "2022-09-29 09",
      end_date_time = "2022-09-29 13"
    )
  })
  expect_equal(nrow(res), 5)
})


test_that("works with station_id as a vector", {
  vcr::use_cassette("hourly_station_vector", {
    res <-
      az_hourly(
        station_id = c(1, 2),
        start_date_time = dt,
        end_date_time = dt
      )
  })
  expect_s3_class(res, "data.frame")
  expect_equal(unique(res$meta_station_id), c("az01", "az02"))
})

test_that("data is in correct format", {
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$eto_pen_mon_in, "double")
  expect_s3_class(res_default$datetime_last, "Date")
})
