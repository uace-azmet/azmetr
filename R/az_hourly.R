#' Retrieve Hourly Weather Data
#'
#' @param station_id station ID can be supplied as numeric vector (e.g.
#'   `station_id = c(8, 37)`) or as character vector with the prefix "az" and 2
#'   digits (e.g. `station_id = c("az08", "az37")`) If left blank data for all
#'   stations will be returned
#' @param start_date_time character; in YYYY-MM-DD HH or another format that can be
#'   parsed by [lubridate::ymd_h()]
#' @param end_date_time character; in YYYY-MM-DD in YYYY-MM-DD HH or another format that
#'   can be parsed by [lubridate::ymd_h()].  Defaults to the current time if left
#'   blank.
#' @details If neither `start_date_time` nor `end_date_time` are supplied, the
#'   most recent day of data will be returned.  If only `start_date_time` is
#'   supplied, then `end_date_time` defaults to the current time.  Supplying
#'   only `end_date_time` will result in an error.
#' @note If `station_id` is supplied as a vector, multiple successive calls to
#'   the API will be made.  You may find better performance getting data for all
#'   the stations by leaving `station_id` blank and subsetting the resulting
#'   dataframe.
#' @return a data frame
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

# Parse station IDs -------------------------------------------------------
  if(!is.null(station_id)) {
    if(is.numeric(station_id)) {
      #add leading 0 if < 10
      station_id <- formatC(station_id, flag = 0, width = 2)
      station_id <- paste0("az", station_id)
    }
    # Validate station IDs
    if(!all(grepl("^az\\d{2}$", station_id))) {
      stop("`station_id` must be numeric or character in the format 'az01'")
    }
  } else {
    station_id <- "*"
  }

# Check that args make sense ----------------------------------------------
  if(!is.null(end_date_time) & is.null(start_date_time)) {
    stop("If you supply `end_date_time`, you must also supply `start_date_time`")
  }

# Parse Dates -------------------------------------------------------------
  if(!is.null(start_date_time)) {
    start_date_time <-
      withCallingHandlers(
        lubridate::ymd_h(start_date_time),
        warning = function(w) {
          if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
            stop("`start_date_time` failed to parse", call. = FALSE)
          }
        }
      )

    start_f <- format(start_date_time, format = "%Y-%m-%dT%H:%M")
  } else {
    start_f <- "*" #default is today
  }

  if(!is.null(end_date_time)) {
    end_date_time <-
      withCallingHandlers(
        lubridate::ymd_h(end_date_time),
        warning = function(w) {
          if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
            stop("`end_date_time` failed to parse", call. = FALSE)
          }
        }
      )
  } else {
    end_date_time <- lubridate::now()
  }

  if ((!is.null(start_date_time))) {
    if(end_date_time < start_date_time) {
      stop("`end_date_time` is before `start_date_time`!")
    }

# Construct time interval for API -----------------------------------------
    d <- lubridate::as.period(end_date_time - start_date_time)
    time_interval <- lubridate::format_ISO8601(d)
  } else {
    time_interval <- "*"
  }

# Function to query API ---------------------------------------------------
  retrieve_hourly <- function(station_id, start_f, time_interval) {
    path <- c("v1", "observations", "hourly", station_id, start_f, time_interval)
    res <- httr::GET(base_url, path = path, httr::accept_json())
    check_status(res)
    data_raw <- httr::content(res, as = "parsed")
    data_tidy <- data_raw$data |>
      purrr::map_df(tibble::as_tibble)

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

# Query API and wrangle output --------------------------------------------
  if (length(station_id) == 1) {
    out <- retrieve_hourly(station_id, start_f, time_interval)
  } else if (length(station_id) > 1) {
    out <- purrr::map_df(station_id, function(x) retrieve_hourly(x, start_f, time_interval))
  }
  out
  out |>
    #move metadata to beginning
    dplyr::select(dplyr::starts_with("meta_"), dplyr::everything()) |>
    dplyr::mutate(dplyr::across(c(-"meta_station_id", -"meta_station_name", -"date_datetime", -"date_hour"), as.numeric)) |>
    dplyr::mutate(date_datetime = lubridate::ymd_hms(date_datetime))
}
