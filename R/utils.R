check_internet <- function(){
  attempt::stop_if_not(.x = curl::has_internet(), msg = "Please check your internet connexion")
}

ping_service <- function() {
  resp <-
    httr2::request(base_url) %>%
    httr2::req_url_path_append("observations", "daily", "az01") %>%
    httr2::req_error(is_error = function(resp) FALSE) %>%
    httr2::req_method("HEAD") %>%
    httr2::req_user_agent("azmetr (https://github.com/uace-azmet/azmetr)") %>% 
    httr2::req_perform() 

  status <- httr2::resp_status(resp)
  if(status == 200){
    return(TRUE)
  } else {
    return(FALSE)
  }
}

base_url <- "https://api.azmet.arizona.edu/v1/"
