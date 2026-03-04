#' Assign units using the `units` package
#'
#' Assigns correct units to the output of `az_hourly()`, `az_daily()`, and
#' `az_heat()` using the `units` package.
#'
#' @param x A tibble output by [az_hourly()], [az_daily()], or [az_heat()]
#'
#' @return A tibble with columns of class "units"
#' @export
#'
#' @examples
#' \dontrun{
#' daily <- az_daily()
#'
#' daily_units <-
#'   az_add_units(daily)
#'
#' #unit conversions with `units::set_units()`
#' daily_units$sol_rad_total %>% units::set_units("kW h m-2")
#'
#' #units carry through calculations
#' climatic_balance <-
#'   daily_units$precip_total_mm - daily_units$eto_pen_mon
#' climatic_balance
#' }
#'
az_add_units <- function(x) {
  rlang::check_installed("units")
  x %>%
    dplyr::mutate(dplyr::across(
      c(
        dplyr::matches("temp_.+C"),
        dplyr::matches("heat.+C"),
        dplyr::starts_with("dwpt"),
        dplyr::any_of(c(
          "dwpt",
          "dwpt_mean",
          "dwpt",
          "dwpt_30cm"
        ))
      ),
      function(x) units::set_units(x, "degC")
    )) %>%
    dplyr::mutate(dplyr::across(
      c(
        dplyr::matches("temp_.+F"),
        dplyr::matches("heat.+F"),
        dplyr::any_of(c(
          "dwpt_meanF",
          "dwptF"
        ))
      ),
      function(x) units::set_units(x, "degF")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::matches("^wind_.*_dir"),
      function(x) units::set_units(x, "degrees")
    )) %>%
    dplyr::mutate(dplyr::across(
      c(
        dplyr::ends_with("_in"),
        dplyr::ends_with("_in_sum")
      ),
      function(x) units::set_units(x, "in")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::starts_with("chill_hours"),
      function(x) units::set_units(x, "hours")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::starts_with("vp_"),
      function(x) units::set_units(x, "kPa")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of(c(
        "sol_rad_total_ly"
      )),
      function(x) units::set_units(x, "langleys")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of(c(
        "sol_rad_total"
      )),
      function(x) units::set_units(x, "MJ m-2")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of("sol_rad_kWm2"),
      function(x) units::set_units(x, "kW m-2")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of(c(
        "eto_azmet",
        "precip_total",
        "eto_pen_mon",
        "precip_total_mm"
      )),
      function(x) units::set_units(x, "mm")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::matches("^wind.*_mph$"),
      function(x) units::set_units(x, "miles/hr")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::matches("^wind.*_mps"),
      function(x) units::set_units(x, "m/s")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of(c(
        "wind_vector_magnitude"
      )),
      function(x) units::set_units(x, "m/s")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of(c(
        "meta_bat_volt",
        "meta_bat_volt_max",
        "meta_bat_volt_mean",
        "meta_bat_volt_min"
      )),
      function(x) units::set_units(x, "V")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::starts_with("relative_humidity"),
      function(x) units::set_units(x, "%")
    )) %>%
    dplyr::mutate(dplyr::across(
      dplyr::matches("lw.+_mV$"),
      function(x) units::set_units(x, "mV")
    )) %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("_mins"), function(x) {
      units::set_units(x, "minute")
    }))
}

