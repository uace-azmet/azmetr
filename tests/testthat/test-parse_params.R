library(lubridate)
calc_end_date <- function(params) {
  (lubridate::ymd_hm(params$start_f) + lubridate::as.duration(params$time_interval)) %>%
    format("%Y-%m-%dT%H:%M")
}
test_that("station_id gets parsed", {
  expect_equal(parse_params(station_id = 1, start = NULL, end = NULL)$station_id, "az01")
  expect_equal(parse_params(station_id = "az01", start = NULL, end = NULL)$station_id, "az01")
  expect_error(parse_params(station_id = "a01", start = NULL, end = NULL))
  expect_error(parse_params(station_id = 200, start = NULL, end = NULL))
  expect_error(parse_params(station_id = TRUE, start = NULL, end = NULL))
})

test_that("accepts datetimes in different formats", {
  params_dt1 <-
    parse_params(
      station_id = 1,
      start = "2022-09-09 12",
      end = "2022-09-10 12",
      hour = TRUE
    )
  expect_type(params_dt1, "list")
  expect_equal(params_dt1$start_f, "2022-09-09T12:00")
  expect_equal(calc_end_date(params_dt1), "2022-09-10T12:00")

  params_dt2 <-
    parse_params(
      station_id = 1,
      start = "2022-09-09 12:00",
      end = "2022-09-10 12:00",
      hour = TRUE
    )
  expect_equal(params_dt2$start_f, "2022-09-09T12:00")
  expect_equal(calc_end_date(params_dt2), "2022-09-10T12:00")


  params_dt3 <-
    parse_params(
      station_id = 1,
      start = lubridate::ymd_hm("2022-09-09 12:00"),
      end = lubridate::ymd_hm("2022-09-10 12:00"),
      hour = TRUE
    )
  expect_equal(params_dt3$start_f, "2022-09-09T12:00")
  expect_equal(calc_end_date(params_dt3), "2022-09-10T12:00")

})

test_that("dates get rounded to correct datetime when hour = TRUE", {
  params_dt4 <-
    parse_params(
      station_id = 1,
      start = "2022-09-09",
      end = "2022-09-10",
      hour = TRUE
    )
  expect_equal(params_dt4$start_f, "2022-09-09T01:00")
  expect_equal(params_dt4$time_interval, "P1DT23H")
})

test_that("dates are accepted in different formats", {
  params_d1 <-
    parse_params(
      station_id = 1,
      start = "2022-09-09",
      end = "2022-09-10",
      hour = FALSE
    )
  expect_type(params_d1, "list")
  expect_equal(params_d1$start_f, "2022-09-09T00:00")
  expect_equal(calc_end_date(params_d1), "2022-09-10T00:00")

  params_d2 <-
    parse_params(
      station_id = 1,
      start = "2022/09/09",
      end = "2022/09/10",
      hour = FALSE
    )
  expect_equal(params_d2$start_f, "2022-09-09T00:00")
  expect_equal(calc_end_date(params_d2), "2022-09-10T00:00")

  params_d3 <-
    parse_params(
      station_id = 1,
      start = lubridate::ymd("2022/09/09"),
      end = lubridate::ymd("2022/09/10"),
      hour = FALSE
    )
  expect_equal(params_d3$start_f, "2022-09-09T00:00")
  expect_equal(calc_end_date(params_d3), "2022-09-10T00:00")

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
  params_1h <-
    parse_params(station_id = 1,
                 start = "2023-10-21 23:00",
                 end = "2023-10-21 23:59",
                 hour = TRUE)
  #even though these are not exactly an hour apart, the API considers them an hour apart
  expect_equal(params_1h$time_interval, "PT1H")
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

test_that("messages and warnings are correct", {
  expect_no_error(parse_params(1, start = lubridate::today()-days(1), end = NULL))
  expect_no_error(parse_params(1, start = NULL, end = NULL, hour = TRUE))
  expect_no_error(parse_params(1, start = "2023-10-23 23", end = "2023-10-23 23:59"))
})

test_that("start and end has to be earlier than now", {
  expect_error(
    parse_params(1, start = format(lubridate::now(), "%Y-%m-%d %H"), end = NULL, hour = TRUE),
    "Please supply a `start_date_time` earlier than now."
  )
  expect_error(
    parse_params(1, start = NULL, end = format(lubridate::now(), "%Y-%m-%d %H"), hour = TRUE),
    "Please supply an `end_date_time` earlier than now."
  )
  expect_error(
    parse_params(1, start = lubridate::today(), end = NULL),
    "Please supply a `start_date` earlier than today."
  )
  expect_error(
    parse_params(1, start = NULL, end = lubridate::today()),
    "Please supply an `end_date` earlier than today."
  )
})
