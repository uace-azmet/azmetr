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
  #TODO: this got real complicated real fast.  Could probably benefit from
  #refactoring at some point
  if(hour) {
    # Using parse_date_time allows user to input POSIXct (YmdHMS) or a character
    # value with at least year, month, day, and hour (e.g. "2022/01/12 13")
    parse_fun <- function(x, end = FALSE) {
      parsed <- lubridate::parse_date_time(x, orders = c("YmdHMS", "YmdHM", "YmdH", "Ymd"))
      # if end date and only ymd is supplied, round up to end of day.
      # AZMet uses days that go from 1:00:00 to 23:59:59
      if(is_ymd(x) & isTRUE(end)) {
        lubridate::hour(parsed) <- 23
        lubridate::minute(parsed) <- 59
        lubridate::second(parsed) <- 59

      } else {
        parsed <- parsed %>%
          lubridate::floor_date(unit = "min")
      }
      parsed
    }
  } else {
    parse_fun <- function(x, end = FALSE) {
      lubridate::parse_date_time(x, orders = c("Ymd", "YmdHMS", "YmdHM", "YmdH")) %>%
        lubridate::floor_date(unit = "day") %>%
        lubridate::as_date()
    }
  }

  if(!is.null(start)) {
    #capture parsing warning and turn it into an error
    start_parsed <-
      withCallingHandlers(
        parse_fun(start),
        warning = function(w) {
          if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
            stop("`start_date` failed to parse", call. = FALSE)
          }
        }
      )
    start_f <- format(start_parsed, format = "%Y-%m-%dT%H:%M")
  } else {
    start_f <- "*" #default is today
  }

  if(!is.null(end)) {
    #capture parsing warning and turn it into an error
    end_parsed <-
      withCallingHandlers(
        parse_fun(end, end = TRUE),
        warning = function(w) {
          if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
            stop("`end_date` failed to parse", call. = FALSE)
          }
        }
      )
  } else {
    if (hour) {
      #API is always about one timestep behind
      end_parsed <- lubridate::now() - lubridate::hours(1)
    } else {
      end_parsed <- lubridate::today() - lubridate::days(1)
    }
  }

  if (!is.null(start)) {
    if(end_parsed < start_parsed) {
      stop("`end_date` is before `start_date`!")
    }


    # Construct time interval for API -----------------------------------------
    # round_date() is necessary here because although the AZMet API counts
    # 23:59 as a valid time, it considers the time interval between 23 and 23:59
    # as one full hour.
    d <- lubridate::as.period(
      lubridate::round_date(end_parsed, unit = "hour") - lubridate::round_date(start_parsed, unit = "hour")
    )
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


is_ymd <- function(x) {
  !is.na(lubridate::ymd(x, quiet = TRUE))
}
