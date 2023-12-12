#' Retrieve data from AZMet API
#'
#' @param station_id character; in the format of "az01"
#' @param start_f character; ISO formatted date time string
#' @param time_interval character; ISO8601 formatted time interval string
#' @param endpoint character; one of "daily", "hourly", or "hueto"
#' @param print_call logical; when TRUE, prints the HTTP request to the AZMet API
#'
#' @return tibble
#' @noRd
#'
retrieve_data <- function(station_id, start_f, time_interval,
                          endpoint = c("daily", "hourly", "hueto"),
                          print_call = getOption("azmet.print_api_call")) {
  endpoint <- match.arg(endpoint)

  req <- httr2::request(base_url) %>%
    httr2::req_method("GET") %>%
    httr2::req_url_path_append("observations", endpoint, station_id, start_f, time_interval) %>%
    httr2::req_headers("Accept" = "application/json") %>%
    #limit rate to 4 calls per second
    httr2::req_throttle(4 / 1)

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
    purrr::map_df(tibble::as_tibble)

  attributes(data_tidy) <-
    append(attributes(data_tidy), list(
      i = data_raw$i,
      l = data_raw$l,
      s = data_raw$s,
      t = data_raw$t
    ))
  data_tidy
  #TODO: check for 0x0 tibble and error
}
