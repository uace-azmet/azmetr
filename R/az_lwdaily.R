#' Retrieve Daily Leaf Wetness Data from AZMet
#'
#' Retrieves daily leaf wetness data from the Arizona Meteorological Network
#' API. Currently, these data only are available from weather stations in the
#' Yuma area. For a list of stations and their locations see [station_info], or
#' visit https://azmet.arizona.edu/about.
#'
#' @param station_id station ID can be supplied as numeric vector (e.g.
#'   `station_id = c(8, 37)`) or as character vector with the prefix "az" and
#'   two digits (e.g. `station_id = c("az08", "az37")`). If left blank, data for
#'   all stations will be returned.
#' @param start_date A length-1 vector of class Date, POSIXct, or character in
#'   YYYY-MM-DD format. Will be rounded **down** to the nearest day if more
#'   precision is supplied. Defaults to the day before the current date (i.e.,
#'   the most recent complete day) if left blank.
#' @param end_date A length-1 vector of class Date, POSIXct, or character in
#'   YYYY-MM-DD format. Will be rounded **down** to the nearest day if more
#'   precision is supplied. Defaults to the day before the current date (i.e.,
#'   the most recent complete day) if left blank.
#' @details If neither `start_date` nor `end_date` are supplied, the most recent
#'   day of data will be returned. If only `start_date` is supplied, then the
#'   end date defaults to the day before the current date (i.e., the most recent
#'   complete day). Supplying only `end_date` will result in an error.
#' @note If `station_id` is supplied as a vector, multiple successive calls to
#'   the API will be made. You may find better performance getting data for all
#'   the stations by leaving `station_id` blank and subsetting the resulting
#'   dataframe. Requests for data from all stations for more than 6-12 months
#'   may take considerable time.
#' @return A tibble. For units and other metadata, see
#'   <https://azmet.arizona.edu/about>
#' @seealso [az_15min()], [az_daily()], [az_heat()], [az_hourly()], [az_lw15min()]
#' @source <https://azmet.arizona.edu/>
#'
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' \dontrun{
#' # Most recent data for all stations:
#' az_lwdaily()
#'
#' # Specify stations:
#' az_lwdaily(station_id = c(1, 2))
#' az_lwdaily(station_id = c("az01", "az02"))
#'
#' # Specify dates:
#' az_lwdaily(start_date = "2022-09-25")
#' az_lwdaily(start_date = "2022-09-25", end_date = "2022-09-26")
#' }


az_lwdaily <- function(station_id = NULL, start_date = NULL, end_date = NULL) {

  # TODO: check for valid station IDs
  check_internet()

  if(!is.null(end_date) & is.null(start_date)) {
    stop("If you supply `end_date`, you must also supply `start_date`.")
  }

  params <-
    parse_params(
      station_id = station_id,
      start = start_date,
      end = end_date,
      hour = FALSE,
      real_time = FALSE
    )


  # Query API  -----------------------------------------------------------------

  if (is.null(start_date) & is.null(end_date)) {
    message("Querying data from ", params$start, " ...")
  } else {
    message("Querying data from ", params$start, " through ", params$end, " ...")
  }

  if (length(station_id) <= 1) {
    out <-
      retrieve_data(
        params$station_id,
        params$start_f,
        params$time_interval,
        endpoint = "lwdaily"
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
            endpoint = "lwdaily"
          )
        }
      )
  }

  if (nrow(out) == 0) {
    warning("No data retrieved from API")
    # Return 0x0 tibble for type consistency
    return(tibble::tibble())
  }

  # Check if any data are missing
  n_obs <- out %>%
    dplyr::summarise(n = dplyr::n(), .by = dplyr::all_of("meta_station_id")) %>%
    dplyr::filter(.data$n < as.numeric(lubridate::period(params$time_interval), "day") + 1)
  if (nrow(n_obs) != 0 |
     # Also warn if the missing data is just at the end
     lubridate::ymd(max(out$date)) < params$end) {
    warning("Some requested data were unavailable.")
  }


  # Wrangle output -------------------------------------------------------------

  out <- out %>%
    # Move metadata to beginning
    dplyr::select(dplyr::starts_with("meta_"), dplyr::everything()) %>%
    dplyr::mutate(dplyr::across(
      c(-"meta_station_id", -"meta_station_name", -"date", -"datetime"),
      as.numeric
    )) %>%
    # As of March 7, 2024, let Test station data through
    #dplyr::filter(.data$meta_station_id != "az99") %>%
    dplyr::mutate(date = lubridate::ymd(.data$date)) %>%
    dplyr::mutate(
      datetime = lubridate::ymd_hms(.data$datetime, tz = "America/Phoenix")
    ) %>%
    # Convert NAs
    dplyr::mutate(
      dplyr::across(
        tidyselect::where(is.numeric),
        function(x) {
          dplyr::if_else(
            x %in% c(-999, -9999, -99999, -7999, 999, 999.9, 9999),
            NA_real_,
            x
          )
        }
      )
    ) %>%
    add_labels_lwdaily()

  if (length(unique(out$date)) == 1) {
    message("Returning data from ", unique(out$date))
  } else {
    message("Returning data from ", min(out$date), " through ", max(out$date))
  }
  return(out)
}
