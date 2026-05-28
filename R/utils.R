check_internet <- function(){
  attempt::stop_if_not(.x = curl::has_internet(), msg = "Please check your internet connexion")
}

check_status <- function() {
  req <-
    httr2::request(base_url) %>%
    httr2::req_url_path_append("status") %>%
    httr2::req_error(is_error = function(resp) FALSE) %>%
    httr2::req_user_agent("azmetr (https://github.com/uace-azmet/azmetr)")

  resp <- httr2::req_perform(req)
  http_status <- httr2::resp_status(resp)
  if (http_status != 200) {
    return(list(status = http_status))
  } else {
    httr2::resp_body_json(resp)
  }
}

ping_service <- function() {
  status <- check_status()
  if (status$status == "OK" & status$statusdb == "OK") {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

base_url <- "https://api.azmet.arizona.edu/v1/"
