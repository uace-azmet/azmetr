az_daily <- function(station_id = NULL, date_time_start = NULL, time_interval = NULL) {
  check_internet()
  path <- c("v1", "observations", "daily")

  #validate and URL encode args

  if(!is.null(station_id)) {
    #TODO: figure out what station IDs are valid
    #validation
  } else {
    station_id <- "*"
  }

  if(!is.null(date_time_start)) {
  #"Start date time must be in a valid date time in formatted as YYYY-MM-DDTHH:MM."
    if(is.character(date_time_start)) {
      date_time_start <- lubridate::ymd_hm(date_time_start)
    }
    date_time_start <- format(date_time_start, format = "%Y-%m-%dT%H:%M")
  } else {
    date_time_start <- "*"
  }

  if(!is.null(time_interval)) {
    #TODO figure out if there is an "R" way to supply this or if this note should just be in the documentation:

  #"Collection interval must be in a valid ISO-8601 interval format: P1DT23H, where 1 is number of days and 23 is the number of hours."

  } else {
    time_interval <- "*"
  }

  res <- httr::GET(base_url, path = path, accept_json())
  check_status(res)
  data_raw <- parsed_content(res)
  #TODO: parse into dataframe with errors as attributes and return
  data_raw
}
