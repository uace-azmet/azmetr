test_that("all columns get assigned units that should", {
  vcr::use_cassette("daily_units", {
    res_daily <- az_daily()
  })
  vcr::use_cassette("hourly_units", {
    res_hourly <- az_hourly()
  })
  vcr::use_cassette("heat_units", {
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
      dplyr::select(-starts_with("meta_"), -starts_with("date_")) %>%
      purrr::map_lgl(~inherits(.x, "units")) %>%
      all()
  )
  expect_true(
    daily_units %>%
      dplyr::select(-starts_with("meta_"), -datetime, -starts_with("date_")) %>%
      purrr::map_lgl(~inherits(.x, "units")) %>%
      all()
  )
})
