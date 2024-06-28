#' Parse input parameters for AZMet API
#'
#' @param station_id character or numeric vector
#' @param start start date or date time
#' @param end end date or date time
#' @param hour logical; do `start` and `end` contain hours?
#' @param lwdaily logical; is request for daily leaf wetness data?
#' @param real_time logical; is request for real-time data?
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


parse_params <- function(station_id, start, end, hour = FALSE, lwdaily = FALSE, real_time = FALSE) {

  is_ymd <- function(x) {
    !is.na(lubridate::ymd(x, quiet = TRUE))
  }

  tz <- "America/Phoenix"


  # Parse station IDs ----------------------------------------------------------

  if(!is.null(station_id)) {
    if(is.numeric(station_id)) {
      # Add leading 0 if < 10
      station_id <- formatC(station_id, flag = 0, width = 2)
      station_id <- paste0("az", station_id)
    }

    # Validate station IDs
    if(!all(grepl("^az\\d{2}$", station_id))) {
      stop("`station_id` must be numeric or character in the format 'az01'.")
    }

    active_stations <-  azmetr::station_info$meta_station_id

    if(!all(station_id %in% active_stations)) {
      stop("Invalid `station_id`")
    }
  } else {
    station_id <- "*"
  }


  # Set Date Defaults ----------------------------------------------------------

  ## Variable dictionary ##################
  # end/start: user input used for conditionals, character
  # end_/start_: initial defaults, character
  # end_parsed/start_parsed: used for messages and validation, datetime
  # start_f/time_interval: what is actually passed to the API
  #########################################


  if (is.null(end)) {
    if (isTRUE(hour)) { # Hourly data
      end_ <- format( # Keep as character until later, for consistency
        lubridate::floor_date(lubridate::now(tzone = tz), "hour"),
        "%Y-%m-%d %H:%M:%S"
      )
    } else if (isTRUE(real_time)) { # 15min data, both weather and leaf wetness
      end_ <- format( # Keep as character until later, for consistency
        lubridate::now(tzone = tz),
        "%Y-%m-%d %H:%M:%S"
      )
    } else if (isTRUE(lwdaily)) { # Daily leaf wetness data
      end_ <- paste( # Keep as character until later, for consistency
        lubridate::today(tzone = tz) - lubridate::days(1),
        "23:59:59"
      )
    } else { # Daily weather and leaf wetness data
      end_ <- format( # Keep as character until later, for consistency
        lubridate::today(tzone = tz) - lubridate::days(1),
        "%Y-%m-%d %H:%M:%S"
      )
    }
  } else {
    # For hourly, if only ymd is supplied to `end`, round up to end of day. On a
    # given day, hourly data go from 1:00:00 to 23:59:59. For 15min, if only ymd
    # is supplied to `end`, set to current Arizona time. On a given day, 15 min
    # data go from 00:00:01 to 23:59:59
    if (isTRUE(hour) & is_ymd(end)) { # Hourly data
      end_ <- paste(end, "23:59:59")
    } else if (isTRUE(real_time) & is_ymd(end)) { # 15min data
      end_ <- paste(end, format(lubridate::now(tzone = tz), "%H:%M:%S"))
    } else if (isTRUE(lwdaily)) { # Daily leaf wetness data
      end_ <- paste(end, "23:59:59")
    } else { # Daily weather data
      end_ <- end
    }
  }

  if (is.null(start)) {
    if (isTRUE(hour)) { # Hourly data
      start_ <- format( # Keep as character until later, for consistency
        lubridate::floor_date(lubridate::now(tzone = tz), "hour") - lubridate::hours(1),
        "%Y-%m-%d %H:%M:%S"
      )
    } else if (isTRUE(real_time)) { # 15min data
      start_ <- format( # Keep as character until later, for consistency
        lubridate::now(tzone = tz) - lubridate::minutes(15),
        "%Y-%m-%d %H:%M:%S"
      )
    } else if (isTRUE(lwdaily)) { # Daily leaf wetness data
      start_ <- paste( # Keep as character until later, for consistency
        lubridate::today(tzone = tz) - lubridate::days(1),
        "23:00:00"
      )
    } else { # Daily weather data
      start_ <- format( # Keep as character until later, for consistency
        lubridate::today(tzone = tz) - lubridate::days(1),
        "%Y-%m-%d"
      )
    }
  } else {
    if (isTRUE(hour) & is_ymd(start)) { # Hourly data
      start_ <- paste(start, "01:00:00")
    } else if (isTRUE(real_time) & is_ymd(start)) { # 15min data
      start_ <- paste(start, "00:00:01")
    } else if (isTRUE(lwdaily)) { # Daily leaf wetness data
      start_ <- paste(start, "23:00:00")
    } else { # Daily weather and leaf wetness data
      start_ <- start
    }
  }


  # Parse dates/datetimes ---------------------------------------------------

  # Rather than applying the parsing directly, I create a function so that later
  # on it can be wrapped in `withCallingHandlers` to capture and transform error
  # messages
  if (isTRUE(hour)) { # Hourly data
    # Using parse_date_time allows user to input POSIXct (YmdHMS) or a character
    # value with at least year, month, day, and hour (e.g. "2022/01/12 13")
    parse_fun <- function(x, end = FALSE) {
      lubridate::parse_date_time(x, orders = c("YmdHMS", "YmdHM", "YmdH", "Ymd"), tz = tz) %>%
        lubridate::floor_date(unit = "min")
    }
  } else if (isTRUE(real_time)) { # 15min data
    parse_fun <- function(x, end = FALSE) {
      lubridate::parse_date_time(x, orders = c("YmdHMS", "YmdHM", "YmdH", "Ymd"), tz = tz) %>%
        lubridate::floor_date(unit = "secs")
    }
  } else if (isTRUE(lwdaily)) { # Daily leaf wetness data
    parse_fun <- function(x, end = FALSE) {
      lubridate::parse_date_time(x, orders = c("YmdHMS", "YmdHM", "YmdH", "Ymd"), tz = tz) %>%
        lubridate::floor_date(unit = "min")
    }
  } else { # Daily weather data
    parse_fun <- function(x, end = FALSE) {
      lubridate::parse_date_time(x, orders = c("Ymd", "YmdHMS", "YmdHM", "YmdH"), tz = tz) %>%
        lubridate::floor_date(unit = "day") %>%
        lubridate::as_date()
    }
  }

  # Capture parsing warning and turn it into an error
  start_parsed <-
    withCallingHandlers(
      parse_fun(start_),
      warning = function(w) {
        if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
          stop("`start_date` failed to parse.", call. = FALSE)
        }
      }
    )

  # If start wasn't supplied, then we actually pass "*" to the API as a default
  # to get the most recent data. However, we don't want the default behavior if it is hourly data
  if (is.null(start) & isFALSE(hour)) {
    start_f <- "*"
  } else {
    start_f <- format(start_parsed, format = "%Y-%m-%dT%H:%M")
  }

  # Capture parsing warning and turn it into an error
  end_parsed <-
    withCallingHandlers(
      parse_fun(end_, end = TRUE),
      warning = function(w) {
        if (conditionMessage(w) == "All formats failed to parse. No formats found.") {
          stop("`end_date` failed to parse.", call. = FALSE)
        }
      }
    )

  if (isTRUE(hour)) { # Hourly data
    if (!is.null(start) & start_parsed >= lubridate::floor_date(lubridate::now(tzone = tz), "hour")) {
      stop("Please supply a `start_date_time` earlier than now.")
    }
    if (!is.null(end) & end_parsed >= lubridate::floor_date(lubridate::now(tzone = tz), "hour")) {
      stop("Please supply an `end_date_time` earlier than now.")
    }
    if (end_parsed < start_parsed) {
      stop("`end_date_time` is before `start_date_time`!")
    }
  } else if (isTRUE(real_time)) { # 15min data
    if (!is.null(start) & start_parsed > lubridate::now(tzone = tz)) {
      stop("Please supply a `start_date_time` earlier than now.")
    }
    if (!is.null(end) & end_parsed > lubridate::now(tzone = tz)) {
      stop("Please supply an `end_date_time` earlier than now.")
    }
    if (end_parsed < start_parsed) {
      stop("`end_date_time` is before `start_date_time`!")
    }
  } else { # Daily weather and leaf wetness data
    if (!is.null(start) & start_parsed >= lubridate::today(tzone = tz)) {
      stop("Please supply a `start_date` earlier than today.")
    }
    if (!is.null(end) & end_parsed >= lubridate::today(tzone = tz)) {
      stop("Please supply an `end_date` earlier than today.")
    }
    if (end_parsed < start_parsed) {
      stop("`end_date` is before `start_date`!")
    }
  }

  earliest_date <- lubridate::ymd("2021-01-01", tz = tz)

  if (end_parsed < earliest_date | start_parsed < earliest_date) {
    stop("Data are not available before ", earliest_date, ". Please choose a later date.")
  }


  # Construct time interval for API -----------------------------------------

  # round_date() is necessary here because although the AZMet API counts
  # 23:59 as a valid time, it considers the time interval between 23 and 23:59
  # as one full hour.
  if (is.null(start)) {
    time_interval <- "*"
  } else {
    end_rounded <- lubridate::round_date(end_parsed, unit = "hour")
    start_rounded <- lubridate::round_date(start_parsed, unit = "hour")
    d <- lubridate::as.period(end_rounded - start_rounded)
    time_interval <- lubridate::format_ISO8601(d)
  }

  # Return list

  # URLencode isn't strictly necessary, but it'll make the correct error print
  # when a param is not properly specified instead of a generic "bad URL" error
  list(
    station_id = sapply(station_id, utils::URLencode, USE.NAMES = FALSE),
    start = start_parsed, # For messages
    end = end_parsed, # For messages
    start_f = utils::URLencode(start_f), # For API
    time_interval = utils::URLencode(time_interval) # For API
  )
}
