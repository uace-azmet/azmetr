#' Retrieve Daily Weather Data
#'
#' @param station_id station ID can be supplied as numeric vector (e.g.
#'   `station_id = c(8, 37)`) or as character vector with the prefix "az" and 2
#'   digits (e.g. `station_id = c("az08", "az37")`) If left blank data for all
#'   stations will be returned
#' @param start_date character; in YYYY-MM-DD or another format that can be
#'   parsed by [lubridate::ymd()]
#' @param end_date character; in YYYY-MM-DD in YYYY-MM-DD or another format that
#'   can be parsed by [lubridate::ymd()].  Defaults to the current date if left
#'   blank.
#' @details If neither `start_date` nor `end_date` are supplied, the most recent
#'   day of data will be returned.  If only `start_date` is supplied, then the
#'   end date defaults to the current date.  Supplying only `end_date` will
#'   result in an error.
#' @note If `station_id` is supplied as a vector, multiple successive calls to
#'   the API will be made.  You may find better performance getting data for all
#'   the stations by leaving `station_id` blank and subsetting the resulting
#'   dataframe.
#' @return a tibble
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' # Most recent data for all stations:
#' az_daily()
#'
#' # Specify stations:
#' az_daily(station_id = c(1, 2))
#' az_daily(station_id = c("az01", "az02"))
#'
#' # Specify dates:
#' az_daily(start_date = "2022-09-25")
#' az_daily(start_date = "2022-09-25", end_date = "2022-09-26")
#'
az_daily <- function(station_id = NULL, start_date = NULL, end_date = NULL) {

  #TODO: document output columns or link to API docs if appropriate
  #TODO: check for valid station IDs
  check_internet()
  if(!is.null(end_date) & is.null(start_date)) {
    stop("If you supply `end_date`, you must also supply `start_date`")
  }
  params <-
    parse_params(station_id = station_id, start = start_date, end = end_date)

  # Query API  --------------------------------------------
  if (length(station_id) <= 1) {
    out <-
      retrieve_data(params$station_id,
                    params$start,
                    params$time_interval,
                    endpoint = "daily")
  } else if (length(station_id) > 1) {
    out <-
      purrr::map_df(
        params$station_id,
        function(x) {
          retrieve_data(x, params$start, params$time_interval, endpoint = "daily")
        }
      )
  }
 if(nrow(out) == 0) {
   warning("No data retrieved from API")
   #return 0x0 tibble for type consistency
   return(tibble::tibble())
 }
  # Wrangle output ----------------------------------------------------------
  out <- out |>
    #move metadata to beginning
    dplyr::select(dplyr::starts_with("meta_"), dplyr::everything()) |>
    dplyr::mutate(dplyr::across(
      c(-"meta_station_id", -"meta_station_name", -"datetime"),
      as.numeric
    )) |>
    dplyr::mutate(datetime = lubridate::ymd(.data$datetime)) |>
    #convert NAs
    dplyr::mutate(
      dplyr::across(
        tidyselect::where(is.numeric),
        function(x)
          dplyr::if_else(x %in% c(-999, -9999, -99999, -7999, 999, 999.9, 9999), NA_real_, x))
    )
  return(out)
}
