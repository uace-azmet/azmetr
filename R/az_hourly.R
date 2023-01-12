#' Retrieve Hourly Weather Data
#'
#' Retrieves hourly weather data from the Arizona Meteorological Network API.
#' For a list of weather stations and their locations see see [station_info].
#'
#' @param station_id station ID can be supplied as numeric vector (e.g.
#'   `station_id = c(8, 37)`) or as character vector with the prefix "az" and 2
#'   digits (e.g. `station_id = c("az08", "az37")`) If left blank data for all
#'   stations will be returned
#' @param start_date_time A length 1 vector of class POSIXct or character in
#'   YYYY-MM-DD HH format.  Will be rounded **down** to the nearest hour if more
#'   precision is supplied.
#' @param end_date_time A length 1 vector of class POSIXct or character in
#'   YYYY-MM-DD HH format.  Will be rounded **down** to the nearest hour if more
#'   precision is supplied.  Defaults to the current time if left blank.
#' @details If neither `start_date_time` nor `end_date_time` are supplied, the
#'   most recent day of data will be returned.  If only `start_date_time` is
#'   supplied, then `end_date_time` defaults to the current time.  Supplying
#'   only `end_date_time` will result in an error.
#' @note If `station_id` is supplied as a vector, multiple successive calls to
#'   the API will be made.  You may find better performance getting data for all
#'   the stations by leaving `station_id` blank and subsetting the resulting
#'   dataframe.
#' @return a tibble. For units and other metadata, see
#'   <https://ag.arizona.edu/azmet/raw2003.htm>
#' @seealso [az_daily()], [az_heat()]
#' @source <https://ag.arizona.edu/azmet/>
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' # Most recent data for all stations:
#' az_hourly()
#'
#' # Specify stations:
#' az_hourly(station_id = c(1, 2))
#' az_hourly(station_id = c("az01", "az02"))
#'
#' # Specify dates:
#' az_hourly(start_date_time = "2022-09-25 01")
#' az_hourly(start_date_time = "2022-09-25 01", end_date = "2022-09-25 20")
#'
az_hourly <- function(station_id = NULL, start_date_time = NULL, end_date_time = NULL) {

  #TODO: document output columns or link to API docs if appropriate
  #TODO: check for valid station IDs
  check_internet()
  if(!is.null(end_date_time) & is.null(start_date_time)) {
    stop("If you supply `end_date_time`, you must also supply `start_date_time`")
  }
  params <-
    parse_params(station_id = station_id, start = start_date_time,
                 end = end_date_time, hour = TRUE)

  # Query API --------------------------------------------
  if (length(station_id) <= 1) {
    out <-
      retrieve_data(params$station_id,
                    params$start,
                    params$time_interval,
                    endpoint = "hourly")
  } else if (length(station_id) > 1) {
    out <-
      purrr::map_df(
        params$station_id,
        function(x) {
          retrieve_data(x, params$start, params$time_interval, endpoint = "hourly")
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
      c(
        -"meta_station_id",
        -"meta_station_name",
        -"date_datetime",
        -"date_hour"
      ),
      as.numeric
    )) %>%
    dplyr::filter(.data$meta_station_id != "az99") %>%
    dplyr::mutate(date_datetime = lubridate::ymd_hms(.data$date_datetime)) %>%
    #convert NAs
    dplyr::mutate(
      dplyr::across(
        tidyselect::where(is.numeric),
        function(x)
          dplyr::if_else(x %in% c(-999, -9999, -99999, -7999, 999, 999.9, 9999), NA_real_, x))
    )
  return(out)
}
