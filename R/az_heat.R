#' Retrieve Accumulated Heat Units and Evapotranspiration
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
#' @return a data frame
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
az_heat <- function(station_id = NULL, start_date = NULL, end_date = NULL) {

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
  if(!is.null(end_date) & is.null(start_date)) {
    stop("If you supply `end_date`, you must also supply `start_date`")
  }

  # Parse Dates -------------------------------------------------------------
  if(!is.null(start_date)) {
    #capture parsing warning and turn it into an error
    start_date <-
      withCallingHandlers(
        lubridate::ymd(start_date),
        warning = function(w) {
          if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
            stop("`start_date` failed to parse", call. = FALSE)
          }
        }
      )
    start_f <- format(start_date, format = "%Y-%m-%dT%H:%M")
  } else {
    start_f <- "*" #default is today
  }

  if(!is.null(end_date)) {
    #capture parsing warning and turn it into an error
    end_date <-
      withCallingHandlers(
        lubridate::ymd(end_date),
        warning = function(w) {
          if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
            stop("`end_date` failed to parse", call. = FALSE)
          }
        }
      )
  } else {
    end_date <- lubridate::today()
  }

  if ((!is.null(start_date))) {
    if(end_date < start_date) {
      stop("`end_date` is before `start_date`!")
    }


    # Construct time interval for API -----------------------------------------
    d <- lubridate::as.period(end_date - start_date)
    time_interval <- lubridate::format_ISO8601(d)
  } else {
    time_interval <- "*"
  }


  # Function to query API ---------------------------------------------------
  retrieve_heat <- function(station_id, start_f, time_interval) {
    path <- c("v1", "observations", "hueto", station_id, start_f, time_interval)
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
    out <- retrieve_heat(station_id, start_f, time_interval)
  } else if (length(station_id) > 1) {
    out <- purrr::map_df(station_id, function(x) retrieve_heat(x, start_f, time_interval))
  }
  out |>
    #move metadata to beginning
    dplyr::select(starts_with("meta_"), everything()) |>
    dplyr::mutate(across(c(-meta_station_id, -meta_station_name, -datetime_last), as.numeric)) |>
    dplyr::mutate(datetime_last = lubridate::ymd(datetime_last))
}
