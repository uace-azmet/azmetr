skip_if_offline()
skip_if_not(ping_service())
skip_on_cran()

test_that("bad station IDs error", {
  expect_error(
    retrieve_data(
      station_id = "bz01",
      start_f = "*",
      time_interval = "*",
      endpoint = "daily"
    ), "Station requested is not found.")
})

test_that("bad dates error", {
  expect_error(
    retrieve_data(
      station_id = "az01",
      start_f = "now",
      time_interval = "*",
      endpoint = "daily"
    ),
    "Start date time must be in a valid date time in formatted as YYYY-MM-DDTHH:MM.")
})

test_that("bad time interval errors", {
  expect_error(
    retrieve_data(
      station_id = "az01",
      start_f = "*",
      time_interval = "a%20day",
      endpoint = "daily"
    )
  )
})

test_that("multiple errors work", {
  expect_error(
    retrieve_data(
      station_id = "bz01",
      start_f = "now",
      time_interval = "a%20day",
      endpoint = "daily"
    )
  )
})

