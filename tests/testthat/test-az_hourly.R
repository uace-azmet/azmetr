library(lubridate)
# dt <-
#   (lubridate::now() - days(1)) %>%
#   floor_date("hour") %>%
#   format("%Y-%m-%d %H")
dt <- "2022-09-28 12"

test_that("start_date_time works as expected", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("hourly_start", {
    res <- az_hourly(
      station_id = 1,
      start_date_time = "2022-09-29 09",
      end_date_time = "2022-09-29 13"
    )
  })
  expect_equal(nrow(res), 5)
})


test_that("works with station_id as a vector", {
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("hourly_station_vector", {
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
  skip_if_offline()
  skip_if_not(ping_service())
  with_mock_dir("hourly", {
    res_default <- az_hourly(start_date_time = dt, end_date_time = dt)
  })
  expect_type(res_default$meta_station_name, "character")
  expect_type(res_default$precip_total, "double")
  expect_s3_class(res_default$date_datetime, "POSIXct")
})

test_that("no data is returned as 0x0 tibble", {
  with_mock_dir("hourly_nodata", {
    res_nodata <-
      suppressWarnings(az_hourly(start_date_time = "2100-01-01 00", end_date_time = "2100-01-02 00"))
  })
  expect_true(nrow(res_nodata) == 0)
  expect_s3_class(res_nodata, "tbl_df")
})
