#' Retrieve Accumulated Heat Units and Evapotranspiration
#'
#' Retrieves accumulated heat units and reference evapotranspiration units from
#' the Arizona Meteorological Network API. By default, returned values are
#' cumulative since January 1 of the current year. For a list of weather
#' stations and their locations see [station_info], or visit
#' https://azmet.arizona.edu/about.
#'
#' @param station_id station ID can be supplied as numeric vector (e.g.
#'   `station_id = c(8, 37)`) or as character vector with the prefix "az" and 2
#'   digits (e.g. `station_id = c("az08", "az37")`) If left blank data for all
#'   stations will be returned
#' @param start_date A length-1 vector of class Date, POSIXct, or character in
#'   YYYY-MM-DD format.  Will be rounded **down** to the nearest day if more
#'   precision is supplied.
#' @param end_date A length-1 vector of class Date, POSIXct, or character in
#'   YYYY-MM-DD format.  Will be rounded **down** to the nearest day if more
#'   precision is supplied.  Defaults to the current date if left blank. If only
#'   an `end_date` is supplied, then data will be cumulative from the start of
#'   the year of `end_date`.
#' @details Unlike [az_daily()], only one row of data per station is returned,
#'   regardless of `start_date` and `end_date`. However, the data returned is
#'   cumulative over the time period specified by `start_date` and `end_date`.
#' @note If `station_id` is supplied as a vector, multiple successive calls to
#'   the API will be made.  You may find better performance getting data for all
#'   the stations by leaving `station_id` blank and subsetting the resulting
#'   dataframe.
#' @return A tibble. For units and other metadata, see
#'   <https://azmet.arizona.edu/about>
#' @seealso [az_15min()], [az_daily()], [az_hourly()], [az_lw15min()], [az_lwdaily()]
#' @source <https://azmet.arizona.edu/>
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' \dontrun{
#' # Most recent data for all stations:
#' az_heat()
#'
#' # Specify stations:
#' az_heat(station_id = c(1, 2))
#' az_heat(station_id = c("az01", "az02"))
#'
#' # Specify dates:
#' ## Cumulative since October 2022
#' az_heat(start_date = "2022-10-01")
#'
#' ## Cumulative from the first of the year through March
#' yr <- format(Sys.Date(), "%Y")
#'
#' az_heat(end_date = paste(yr, "03", "31", sep = "-"))
#' }
#'
az_heat <- function(station_id = NULL, start_date = NULL, end_date = NULL) {
  tz <- "America/Phoenix"
  # TODO: document output columns or link to API docs if appropriate
  # TODO: check for valid station IDs
  check_internet()
  # If no start date supplied, default is Jan 1 of current year.
  if (is.null(start_date)) {
    if(is.null(end_date)) {
      start_date <- lubridate::floor_date(lubridate::today(tzone = tz), "year")
    } else {
      start_date <- lubridate::floor_date(lubridate::ymd(end_date), "year")
    }
  }
  params <-
    parse_params(
      station_id = station_id,
      start = start_date,
      end = end_date,
      hour = FALSE,
      real_time = FALSE
    )
  # always add a day to time_interval for heat endpoint to match how API works
  if (params$time_interval != "*") {
    params$time_interval <-
      lubridate::format_ISO8601(lubridate::as.period(params$time_interval) +
                                  lubridate::days(1))
  }

  # Query API --------------------------------------------

  message("Querying data from ", format(params$start, "%Y-%m-%d"),
          " through ", format(params$end, "%Y-%m-%d"))

  if (length(station_id) <= 1) {
    out <-
      retrieve_data(params$station_id,
                    params$start_f,
                    params$time_interval,
                    endpoint = "hueto")
  } else if (length(station_id) > 1) {
    out <- purrr::map_df(
      params$station_id,
      function(x) {
        retrieve_data(x,
                      params$start_f,
                      params$time_interval,
                      endpoint = "hueto")
      }
    )
  }

  if(nrow(out) == 0) {
    warning("No data retrieved from API")
    #return 0x0 tibble
    return(tibble::tibble())
  }

  # Wrangle output ----------------------------------------------------------
  out <- out %>%
    #move metadata to beginning
    dplyr::select(dplyr::starts_with("meta_"), dplyr::everything()) %>%
    dplyr::mutate(dplyr::across(
      c(-"meta_station_id", -"meta_station_name", -"datetime_last"),
      as.numeric
    )) %>%
    dplyr::filter(.data$meta_station_id != "az99") %>%
    dplyr::mutate(datetime_last = lubridate::ymd(.data$datetime_last)) %>%
    #convert NAs
    dplyr::mutate(
      dplyr::across(
        tidyselect::where(is.numeric),
        function(x)
          dplyr::if_else(x %in% c(-999, -9999, -99999, -7999, 999, 999.9, 9999), NA_real_, x))
    )

  message("Returning data from ", format(params$start, "%Y-%m-%d"),
          " through ", format(max(out$datetime_last), "%Y-%m-%d"))

  return(out)
}
