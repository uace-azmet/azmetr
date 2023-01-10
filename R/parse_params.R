#' Parse input parameters for AZMet API
#'
#' @param station_id character or numeric vector
#' @param start start date or date time
#' @param end end date or date time
#' @param hour logical; do `start` and `end` contain hours?
#'
#' @note If `hour = TRUE`, `start` and `end` can be character or POSIXct and
#'   will be rounded **down** to the nearest hour.  If character, then they must
#'   at least contain the hour (e.g. "2022-01-12 13" for 1pm on Jan 12, 2022).
#'   If `hour = FALSE` then class Date is also accepted and values will be
#'   rounded **down** to the nearest whole day.  Dates and times should be in
#'   Arizona time.
#'
#' @return a list
#' @noRd
parse_params <- function(station_id, start, end, hour = FALSE) {

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
    active_stations <-  azmetr::station_info$meta_station_id
    if(!all(station_id %in% active_stations)) {
      stop("Invalid `station_id`")
    }
  } else {
    station_id <- "*"
  }

  # Parse Dates -------------------------------------------------------------

  if(hour) {
    # Using parse_date_time allows user to input POSIXct (YmdHMS) or a character
    # value with at least year, month, day, and hour (e.g. "2022/01/12 13")
    parse_fun <- function(x) {
      lubridate::parse_date_time(x, orders = c("YmdHMS", "YmdHM", "YmdH")) %>%
        lubridate::floor_date(unit = "hour")
    }
  } else {
    parse_fun <- function(x) {
      lubridate::parse_date_time(x, orders = c("Ymd", "YmdHMS", "YmdHM", "YmdH")) |>
        lubridate::floor_date(unit = "day") |>
        as_date()
    }
  }

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

  if (!is.null(start)) {
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
