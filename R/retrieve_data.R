#' Title
#'
#' @param station_id numeric or character vector
#' @param start_f ISO formatted date time string
#' @param time_interval ISO8601 formatted time interval string
#' @param endpoint
#'
#' @return
#' @noRd
#'
retrieve_data <- function(station_id, start_f, time_interval,
                          endpoint = c("daily", "hourly", "hueto")) {
  endpoint <- match.arg(endpoint)
  path <- c("v1", "observations", endpoint, station_id, start_f, time_interval)
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
