test_that("all columns get assigned units that should", {
  with_mock_dir("daily_default", {
    res_daily <- az_daily()
  })
  with_mock_dir("hourly_default", {
    res_hourly <- az_hourly()
  })
  with_mock_dir("heat_default", {
    res_heat <- az_heat()
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
