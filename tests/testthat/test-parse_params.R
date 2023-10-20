library(lubridate)
test_that("station_id gets parsed", {
  expect_equal(parse_params(station_id = 1, start = NULL, end = NULL)$station_id, "az01")
  expect_equal(parse_params(station_id = "az01", start = NULL, end = NULL)$station_id, "az01")
  expect_error(parse_params(station_id = "a01", start = NULL, end = NULL))
  expect_error(parse_params(station_id = 200, start = NULL, end = NULL))
  expect_error(parse_params(station_id = TRUE, start = NULL, end = NULL))
})

test_that("accepts dates and date times in different formats", {
  params_dt1 <-
    parse_params(
      station_id = 1,
      start = "2022-09-09 12",
      end = NULL,
      hour = TRUE
    )
  expect_type(params_dt1, "list")
  expect_equal(params_dt1$start, "2022-09-09T12:00")

  params_dt2 <-
    parse_params(
      station_id = 1,
      start = "2022-09-09 12:00",
      end = NULL,
      hour = TRUE
    )
  expect_type(params_dt2, "list")
  expect_equal(params_dt2$start, "2022-09-09T12:00")

  params_dt3 <-
    parse_params(
      station_id = 1,
      start = lubridate::ymd_hm("2022-09-09 12:00"),
      end = NULL,
      hour = TRUE
    )
  expect_type(params_dt3, "list")
  expect_equal(params_dt3$start, "2022-09-09T12:00")

  params_d1 <-
    parse_params(
      station_id = 1,
      start = "2022-09-09",
      end = NULL,
      hour = FALSE
    )
  expect_type(params_d1, "list")
  expect_equal(params_d1$start, "2022-09-09T00:00")

  params_d2 <-
    parse_params(
      station_id = 1,
      start = "2022/09/09",
      end = NULL,
      hour = FALSE
    )
  expect_type(params_d2, "list")
  expect_equal(params_d2$start, "2022-09-09T00:00")

  params_d3 <-
    parse_params(
      station_id = 1,
      start = lubridate::ymd("2022/09/09"),
      end = NULL,
      hour = FALSE
    )
  expect_type(params_d3, "list")
  expect_equal(params_d3$start, "2022-09-09T00:00")

  expect_error(
    parse_params(station_id = 1, start  = "last week", end = NULL),
    "`start_date` failed to parse"
  )
})

test_that("end defaults to yesterday's date", {
  start <- "2022-10-01"
  end <- today() - days(1)
  time_interval <- format_ISO8601(as.period(ymd(end) - ymd(start)))
  params <- parse_params(station_id = NULL, start = start, end = NULL)
  expect_equal(params$time_interval, time_interval)
})

test_that("time_interval is correctly formed", {
  params <-
    parse_params(station_id = 1,
                 start = "2022-09-09",
                 end = "2022-09-10")
  expect_equal(params$time_interval, "P1D")

  params_dt <-
    parse_params(
      station_id = 1,
      start = "2022-09-09 09",
      end = "2022-09-10 10",
      hour = TRUE
    )
  expect_equal(params_dt$time_interval, "P1DT1H")
})

test_that("start and end date combos error correctly", {
  expect_error(
    parse_params(1, start = "2022-09-23", end = "2022-09-22")
  )
  expect_error(
    parse_params(1, start = "2022-09-23 09", end = "2022-09-23 08", hour = TRUE)
  )
})

test_that("invalid station_id error", {
  expect_error(parse_params(3, start = NULL, end = NULL))
  expect_error(parse_params(100, start = NULL, end = NULL))
})
