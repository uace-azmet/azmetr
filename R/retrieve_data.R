#' Retrieve data from AZMet API
#'
#' @param station_id character; in the format of "az01"
#' @param start_f character; ISO formatted date time string
#' @param time_interval character; ISO8601 formatted time interval string
#' @param endpoint character; one of "15min", "daily", "hourly", "hueto", "lw15min", or "lwdaily"
#' @param print_call logical; when TRUE, prints the HTTP request to the AZMet API
#'
#' @return tibble
#' @noRd


retrieve_data <-
  function(
    station_id,
    start_f,
    time_interval,
    endpoint = c("15min", "daily", "hourly", "hueto", "lw15min", "lwdaily"),
    print_call = getOption("azmet.print_api_call")
  ) {

  endpoint <- match.arg(endpoint)

  req <- httr2::request(base_url) %>%
    httr2::req_method("GET") %>%
    httr2::req_url_path_append("observations", endpoint, station_id, start_f, time_interval) %>%
    httr2::req_headers("Accept" = "application/json") %>%
    httr2::req_throttle(capacity =  100, fill_time_s = 60) %>%
    httr2::req_user_agent("azmetr (https://github.com/uace-azmet/azmetr)")

  if (isTRUE(print_call)) {
    print(req)
  }

  resp <- req %>%
    httr2::req_perform()

  data_raw <- httr2::resp_body_json(resp)

  if (length(data_raw$errors) > 0) {
    stop(paste0(data_raw$errors, "\n "))
  }

  data_tidy <- data_raw$data %>%
    purrr::compact() %>%
    purrr::map(purrr::compact) %>% # Removes any columns that are NULL (i.e. no data)
    purrr::map(tibble::as_tibble) %>%
    purrr::list_rbind() # Missing columns for individual sites will be all NAs

  attributes(data_tidy) <-
    append(
      attributes(data_tidy),
      list(i = data_raw$i, l = data_raw$l, s = data_raw$s, t = data_raw$t)
    )
  data_tidy

  # TODO: Check for 0x0 tibble and error
}
