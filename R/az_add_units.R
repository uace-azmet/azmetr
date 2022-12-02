az_add_units <- function(x) {
  rlang::check_installed("units")
  x |>
    dplyr::mutate(across(any_of(c(
      "dwpt",
      "heatstress_cottonC",
      "temp_airC",
      "temp_soil_10cmC",
      "temp_soil_50cmC",
      "dwpt_mean",
      "heatstress_cotton_meanC",
      "temp_air_maxC",
      "temp_air_meanC",
      "temp_air_minC",
      "temp_soil_10cm_maxC",
      "temp_soil_10cm_meanC",
      "temp_soil_10cm_minC",
      "temp_soil_50cm_maxC",
      "temp_soil_50cm_meanC",
      "temp_soil_50cm_minC",
      "heat_units_10C",
      "heat_units_13C",
      "heat_units_3413C",
      "heat_units_7C"
    )), ~units::set_units(., "degC")
    )) |>
    dplyr::mutate(across(any_of(c(
      "dwpt_meanF",
      "heatstress_cotton_meanF",
      "temp_air_maxF",
      "temp_air_meanF",
      "temp_air_minF",
      "temp_soil_10cm_maxF",
      "temp_soil_10cm_meanF",
      "temp_soil_10cm_minF",
      "temp_soil_50cm_maxF",
      "temp_soil_50cm_meanF",
      "temp_soil_50cm_minF",
      "dwptF",
      "heatstress_cottonF",
      "temp_airF",
      "temp_soil_10cmF",
      "temp_soil_50cmF",
      "heat_units_45F",
      "heat_units_50F",
      "heat_units_55F",
      "heat_units_45F_sum",
      "heat_units_9455F",
      "heat_units_50F_sum",
      "heat_units_55F_sum"
    )), ~units::set_units(., "degF")
    )) |>
    dplyr::mutate(across(any_of(c(
      "wind_vector_dir",
      "wind_vector_dir_stand_dev"
    )), ~units::set_units(., "degrees")
    )) |>
    dplyr::mutate(across(c(
      ends_with("_in"),
      ends_with("_in_sum")
      ), ~units::set_units(., "in")
      )) |>
    dplyr::mutate(across(any_of(c(
      "chill_hours_0C",
      "chill_hours_20C",
      "chill_hours_32F",
      "chill_hours_45F",
      "chill_hours_68F",
      "chill_hours_7C"
    )), ~units::set_units(., "hours")
    )) |>
    dplyr::mutate(across(starts_with("vp_"),
                  ~units::set_units(., "kPa")
    )) |>
    dplyr::mutate(across(any_of(c(
      "sol_rad_total_ly"
    )), ~units::set_units(., "langleys")
    )) |>
    dplyr::mutate(across(any_of(c(
      "sol_rad_total"
    )), ~units::set_units(., "MJ m-2")
    )) |>
    dplyr::mutate(across(any_of(c(
      "eto_azmet",
      "precip_total",
      "eto_pen_mon",
      "precip_total_mm"
    )), ~units::set_units(., "mm")
    )) |>
    dplyr::mutate(across(ends_with("_mph"),
                  ~units::set_units(., "mph")
    )) |>
    dplyr::mutate(across(any_of(c(
      "wind_spd_max_mps",
      "wind_spd_mean_mps",
      "wind_spd_mps",
      "wind_vector_magnitude"
    )), ~units::set_units(., "m/s")
    )) |>
    dplyr::mutate(across(any_of(c(
      "meta_bat_volt",
      "meta_bat_volt_max",
      "meta_bat_volt_mean",
      "meta_bat_volt_min"
    )), ~units::set_units(., "V")
    )) |>
    dplyr::mutate(across(any_of(c(
      "relative_humidity_max",
      "relative_humidity_mean",
      "relative_humidity_min",
      "relative_humidity"
    )), ~units::set_units(., "%")
    ))
}

