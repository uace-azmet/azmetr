
test_that("all columns get assigned units that should", {
  with_mock_dir("add_units_mocks", {
    res_daily <-
      az_daily(station_id = 1, start_date = "2023-11-27", end_date = "2023-11-29")
    res_hourly <-
      az_hourly(station_id = 1, start_date_time = "2023-11-28 01", end_date_time = "2023-11-28 12")
    res_heat <-
      az_heat(station_id = 1, end_date = "2023-11-28")
  })
  heat_units <- az_add_units(res_heat)
  hourly_units <- az_add_units(res_hourly)
  daily_units <- az_add_units(res_daily)
  expect_true(
    heat_units %>%
      dplyr::select(-starts_with("meta_"), -datetime_last) %>%
      purrr::map_lgl(~inherits(.x, "units")) %>%
      all()
    )
  expect_true(
    hourly_units %>%
      dplyr::select(
        -starts_with("meta_"),
        -starts_with("date_"),
        -wind_2min_timestamp
      ) %>%
      purrr::map_lgl(~inherits(.x, "units")) %>%
      all()
  )
  expect_true(
    daily_units %>%
      dplyr::select(
        -starts_with("meta_"),
        -datetime,
        -starts_with("date_"),
        -wind_2min_timestamp
      ) %>%
      purrr::map_lgl(~inherits(.x, "units")) %>%
      all()
  )
})
