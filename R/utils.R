check_internet <- function(){
  attempt::stop_if_not(.x = curl::has_internet(), msg = "Please check your internet connexion")
}

check_status <- function(res){
  attempt::stop_if_not(.x = httr::status_code(res),
              .p = ~ .x == 200,
              msg = "The API returned an error")
}

base_url <- "https://api.azmet.arizona.edu/v1/"
