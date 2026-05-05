test_that("all columns get assigned units that should", {
  skip_if_offline()
  skip_if_not(ping_service())
  skip_on_cran()

  res_daily <-
    az_daily(station_id = 1, start_date = "2023-11-27", end_date = "2023-11-29")
  res_hourly <-
    az_hourly(
      station_id = 1,
      start_date_time = "2023-11-28 01",
      end_date_time = "2023-11-28 12"
    )
  res_heat <-
    az_heat(station_id = 1, end_date = "2023-11-28")
  res_15min <- az_15min(
    station_id = 1,
    start = lubridate::now(tzone = "America/Phoenix") - lubridate::hours(24),
    end = lubridate::now(tzone = "America/Phoenix") - lubridate::hours(23)
  )
  res_lw15 <- az_lw15min(
    station_id = 1,
    start = "2026-03-05 12:00:00",
    end = "2026-03-05 13:00:00"
  )
  res_lwdaily <- az_lwdaily(
    station_id = 1,
    start = "2026-03-03",
    end = "2026-03-04"
  )

  heat_units <- az_add_units(res_heat)
  hourly_units <- az_add_units(res_hourly)
  daily_units <- az_add_units(res_daily)
  min15_units <- az_add_units(res_15min)
  lw15min_units <- az_add_units(res_lw15)
  lwdaily_units <- az_add_units(res_lwdaily)
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
  expect_true(
    min15_units %>%
      dplyr::select(
        -starts_with("meta_"),
        -datetime,
        -starts_with("date_"),
      ) %>%
      purrr::map_lgl(~ inherits(.x, "units")) %>%
      all()
  )
  expect_true(
    lw15min_units %>%
      dplyr::select(
        -starts_with("meta_"),
        -datetime,
        -starts_with("date_"),
      ) %>%
      purrr::map_lgl(~ inherits(.x, "units")) %>%
      all()
  )
  expect_true(
    lwdaily_units %>%
      dplyr::select(
        -starts_with("meta_"),
        -date,
        -datetime,
        -starts_with("date_"),
      ) %>%
      purrr::map_lgl(~ inherits(.x, "units")) %>%
      all()
  )
})
