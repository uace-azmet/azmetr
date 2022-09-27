#' Retrieve Daily Weather Data
#'
#' @param station_id station ID can be supplied as numeric vector (e.g.
#'   `station_id = c(8, 37)`) or as character vector with the prefix "az" and 2
#'   digits (e.g. `station_id = c("az08", "az37")`) If left blank data for all
#'   stations will be returned
#' @param date_time_start When to start data return in YYYY-MM-DD HH:MM format.
#'   If left blank the most recent day of data will be returned
#' @param time_interval time interval
#'
#' @return a data frame
#' @export
#'
#' @examples
#' az_daily()
#' TODO: args should be start_date, end_date.  Do the parsing in the function I think.
az_daily <- function(station_id = NULL, date_time_start = NULL, time_interval = NULL) {

  check_internet()

  #validate and URL encode args

  if(!is.null(station_id)) {
    if(is.numeric(station_id)) {
      #add leading 0 if < 10
      station_id <- formatC(station_id, flag = 0, width = 2)
      station_id <- paste0("az", station_id)
    }
    #validation
    if(!all(grepl("$az\\d{2}^", station_id))) {
      stop("`station_id` must be numeric or character in the format 'az01'")
    }

  } else {
    station_id <- "*"
  }

  if(!is.null(date_time_start)) {
  #"Start date time must be in a valid date time in formatted as YYYY-MM-DDTHH:MM."
    if(is.character(date_time_start)) {
      date_time_start <- lubridate::ymd_hm(date_time_start)
    }
    #TODO write tests for datetime, POSIXct, or character inputs
    date_time_start <- format(date_time_start, format = "%Y-%m-%dT%H:%M")
  } else {
    date_time_start <- "*"
  }

  if(!is.null(time_interval)) {

    #"Collection interval must be in a valid ISO-8601 interval format: P1DT23H, where 1 is number of days and 23 is the number of hours."
    #TODO figure out if there is an "R" way to supply this or if this note should just be in the documentation
    #TODO: this isn't only the interval, but the number of results to return.

  } else {
    time_interval <- "*"
  }

  #TODO: if station_id is a vector, this needs to be vectorized.  API can't handle multiple stations.

  path <- c("v1", "observations", "daily", station_id, date_time_start, time_interval)
  res <- httr::GET(base_url, path = path, httr::accept_json())
  check_status(res)
  data_raw <- httr::content(res, as = "parsed")
  data_tidy <- data_raw$data |> purrr::map_df(tibble::as_tibble)
  attributes(data_tidy) <-
    append(attributes(data_tidy), list(
      errors = data_raw$errors,
      i = data_raw$i,
      l = data_raw$l,
      s = data_raw$s,
      t = data_raw$t
      ))
  data_tidy
}
