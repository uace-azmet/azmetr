#' Parse input parameters for AZMet API
#'
#' @param station_id character or numeric vector
#' @param start character; start date or date time that can be parsed by
#'   [lubridate::ymd()] or [lubridate::ymd_h()]
#' @param end character; end date or date time that can be parsed by
#'   [lubridate::ymd()] or [lubridate::ymd_h()]
#' @param hour logical; do `start` and `end` contain hours?
#'
#' @return a list
#' @noRd
parse_params <- function(station_id, start, end, hour = FALSE) {

  if(hour) {
    parse_fun <- lubridate::ymd_h
  } else {
    parse_fun <- lubridate::ymd
  }

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
  if(!is.null(end) & is.null(start)) {
    stop("If you supply `end_date` or `end_date_time`, you must also supply `start_date` or `start_date_time`") #TODO: maybe a method or switch() ?
  }

  # Parse Dates -------------------------------------------------------------
  if(!is.null(start)) {
    #capture parsing warning and turn it into an error
    start <-
      withCallingHandlers(
        parse_fun(start),
        warning = function(w) {
          if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
            stop("`start_date` failed to parse", call. = FALSE)
          }
        }
      )
    start_f <- format(start, format = "%Y-%m-%dT%H:%M")
  } else {
    start_f <- "*" #default is today
  }

  if(!is.null(end)) {
    #capture parsing warning and turn it into an error
    end <-
      withCallingHandlers(
        parse_fun(end),
        warning = function(w) {
          if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
            stop("`end_date` failed to parse", call. = FALSE)
          }
        }
      )
  } else {
    if (hour) {
      end <- lubridate::now()
    } else {
      end <- lubridate::today()
    }
  }

  if ((!is.null(start))) {
    if(end < start) {
      stop("`end_date` is before `start_date`!")
    }


    # Construct time interval for API -----------------------------------------
    d <- lubridate::as.period(end - start)
    time_interval <- lubridate::format_ISO8601(d)
  } else {
    time_interval <- "*"
  }

  #return list
  #URLencode isn't strictly necessary, but it'll make the correct error print
  #when a param is not properly specified instead of a generic "bad URL" error
  list(
    station_id = sapply(station_id, utils::URLencode, USE.NAMES = FALSE),
    start = utils::URLencode(start_f),
    time_interval = utils::URLencode(time_interval)
  )
}
