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

  if (is.null(start) & is.null(end)) {
    #API is always about one timestep behind
    message("Querying data from yesterday")
  }

  if (is.null(end)) {
    end <- lubridate::today(tzone = "America/Phoenix") - lubridate::days(1)
  }

  # For hourly, if end date and only ymd is supplied, round up to end of day.
  # AZMet uses days that go from 1:00:00 to 23:59:59
  if (!is.null(end) & is_ymd(end) & isTRUE(hour)) {
    end <- lubridate::ymd(end)
    lubridate::hour(end) <- 23
    lubridate::minute(end) <- 59
    lubridate::second(end) <- 59
    message("Querying data through ", end)
  }

  #TODO: this got real complicated real fast.  Could probably benefit from
  #refactoring at some point
  if(hour) {
    # Using parse_date_time allows user to input POSIXct (YmdHMS) or a character
    # value with at least year, month, day, and hour (e.g. "2022/01/12 13")
    parse_fun <- function(x, end = FALSE) {
      lubridate::parse_date_time(x, orders = c("YmdHMS", "YmdHM", "YmdH", "Ymd"), tz = "America/Phoenix") %>%
        lubridate::floor_date(unit = "min")
    }
  } else {
    parse_fun <- function(x, end = FALSE) {
      lubridate::parse_date_time(x, orders = c("Ymd", "YmdHMS", "YmdHM", "YmdH"), tz = "America/Phoenix") %>%
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


  if(is.null(end) & !is.null(start)) {
    message("Querying data through ", end_parsed)
  }

  if (!is.null(start)) {
    if(end_parsed < start_parsed) {
      stop("`end_date` is before `start_date`!")
    }


    # Construct time interval for API -----------------------------------------
    # round_date() is necessary here because although the AZMet API counts
    # 23:59 as a valid time, it considers the time interval between 23 and 23:59
    # as one full hour.
    end_rounded <- lubridate::round_date(end_parsed, "hour")
    start_rounded <- lubridate::round_date(start_parsed, unit = "hour")
    d <- lubridate::as.period(end_rounded - start_rounded)
    time_interval <- lubridate::format_ISO8601(d)
  } else {
    time_interval <- "*"
  }

  #not used in API, but useful for warnings, messages and such
  if (hour) {
    end_f <- format(end_parsed, format = "%Y-%m-%d %H:%M:%S")
  } else {
    end_f <- format(end_parsed, format = "%Y-%m-%d")
  }

  #return list
  #URLencode isn't strictly necessary, but it'll make the correct error print
  #when a param is not properly specified instead of a generic "bad URL" error
  list(
    station_id = sapply(station_id, utils::URLencode, USE.NAMES = FALSE),
    start = utils::URLencode(start_f),
    end = end_f,
    time_interval = utils::URLencode(time_interval)
  )
}


is_ymd <- function(x) {
  !is.na(lubridate::ymd(x, quiet = TRUE))
}
