#' Retrieve 15-minute Weather Data from AZMet
#'
#' Retrieves 15-minute data from the AZMet (Arizona Meteorological Network) API.
#' For a list of weather stations and their locations see [station_info].
#'
#' @param station_id Station ID can be supplied as numeric vector (e.g.
#'   `station_id = c(8, 37)`) or as character vector with the prefix "az" and
#'   two digits (e.g. `station_id = c("az08", "az37")`). If left blank, data for
#'   all stations will be returned.
#' @param start_date_time A length-1 vector of class POSIXct or character in
#'   YYYY-MM-DD HH:MM:SS format, in AZ time. If only a date (YYYY-MM-DD) is
#'   supplied, data will be requested starting at 00:00:01 of that day.
#' @param end_date_time A length-1 vector of class POSIXct or character in
#'   YYYY-MM-DD HH:MM:SS format, in AZ time. If only a date (YYYY-MM-DD) is
#'   supplied, data will be requested through the *end* of that day (23:59:59).
#'   Defaults to the current date and time if left blank and `start_date_time`
#'   is specified.
#' @details If neither `start_date_time` nor `end_date_time` are supplied, the
#'   most recent date-time of data will be returned. If only `start_date_time`
#'   is supplied, then `end_date_time` defaults to the current time. Supplying
#'   only `end_date_time` will result in an error.
#' @note If `station_id` is supplied as a vector, multiple successive calls to
#'   the API will be made. You may find better performance getting data for all
#'   the stations by leaving `station_id` blank and subsetting the resulting
#'   dataframe. Only the most recent 48 hours of 15-minute data are stored in
#'   the AZMet API.
#' @return a tibble. For units and other metadata, see
#'   <https://azmet.arizona.edu/about>
#' @seealso [az_daily()], [az_heat()], [az_hourly()], [az_lw15min()]
#' @source <https://azmet.arizona.edu/>
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' \dontrun{
#' # Most recent 15-minute data for all stations:
#' az_15min()
#'
#' # Specify stations:
#' az_15min(station_id = c(1, 2))
#' az_15min(station_id = c("az01", "az02"))
#'
#' # Specify dates:
#' az_15min(start_date_time = "2022-09-25 01:00:00")
#' az_15min(start_date_time = "2022-09-25 01:00:00", end_date_time = "2022-09-25 07:00:00")
#' }


az_15min <- function(station_id = NULL, start_date_time = NULL, end_date_time = NULL) {

  # TODO: check for valid station IDs

  check_internet()

  if (!is.null(end_date_time) & is.null(start_date_time)) {
    stop("If you supply `end_date_time`, you must also supply `start_date_time`.")
  }

  params <-
    parse_params(
      station_id = station_id,
      start = start_date_time,
      end = end_date_time,
      hour = FALSE,
      real_time = TRUE
    )

  tz <- "America/Phoenix"


  # Query API ------------------------------------------------------------------

  if (is.null(start_date_time) & is.null(end_date_time)) {
    message("Querying most recent date-time of 15-minute data ...")
  } else {
    message(
      "Querying data from ", format(params$start, "%Y-%m-%d %H:%M:%S")," through ", format(params$end, "%Y-%m-%d %H:%M:%S"), " ..."
    )
  }

  if (length(station_id) <= 1) {
    out <-
      retrieve_data(
        params$station_id,
        params$start_f,
        params$time_interval,
        endpoint = "15min"
      )
  } else if (length(station_id) > 1) {
    out <-
      purrr::map_df(
        params$station_id,
        function(x) {
          retrieve_data(
            x,
            params$start_f,
            params$time_interval,
            endpoint = "15min"
          )
        }
      )
  }

  # If the most recent date-time is queried, make sure only one date-time is
  # returned per station
  if (is.null(start_date_time) & is.null(end_date_time)) {
    out <-
      out %>%
      dplyr::filter(.data$datetime == max(.data$datetime), .by = "meta_station_id")
  }

  if (nrow(out) == 0) {
    warning("No data retrieved from API.")
    # Return 0x0 tibble
    return(tibble::tibble())
  }

  # Check if any data is missing. Note, this always "passes" when both start and
  # end are NULL (because period("*") is NA)
  #n_obs <- out %>%
  #  dplyr::summarise(n = dplyr::n(), .by = dplyr::all_of("meta_station_id")) %>%
  #  dplyr::filter(.data$n < as.numeric(lubridate::period(params$time_interval), "hour"))
  #if (nrow(n_obs) != 0) {
  #  warning("Some requested data were unavailable.")
  #}

  # Warn if the missing data is just at the end
  if (lubridate::ymd_hms(max(out$datetime), tz = tz) < params$end) {
    warning(
      "You requested data through ", params$end, " but only data through ", max(out$datetime), " were available."
    )
  }


  # Wrangle output -------------------------------------------------------------

  out <- out %>%
    # Move metadata to beginning
    dplyr::select(dplyr::starts_with("meta_"), dplyr::everything()) %>%
    dplyr::mutate(dplyr::across(
      c(-"meta_station_id", -"meta_station_name", -"date_hour", -"datetime"),
      as.numeric
    )) %>%
    dplyr::filter(.data$meta_station_id != "az99") %>%
    dplyr::mutate(
      datetime = lubridate::force_tz(
        lubridate::ymd_hms(.data$datetime),
        tzone = tz
      )
    ) %>%
    # Convert NAs
    dplyr::mutate(
      dplyr::across(
        tidyselect::where(is.numeric),
        function(x)
          dplyr::if_else(x %in% c(-999, -9999, -99999, -7999, 999, 999.9, 9999), NA_real_, x)
      )
    )

  if (length(unique(out$datetime)) == 1) {
    message("Returning data from ", format(unique(out$datetime), "%Y-%m-%d %H:%M:%S"))
  } else {
    message(
      "Returning data from ", format(min(out$datetime), "%Y-%m-%d %H:%M:%S"), " through ", format(max(out$datetime), "%Y-%m-%d %H:%M:%S"))
  }

  return(out)
}
