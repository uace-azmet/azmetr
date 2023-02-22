#shortens file paths created by httptest2 so that R CMD check doesn't complain
httptest2::set_redactor(
  function (resp) {
    resp %>%
    httptest2::gsub_response("api.azmet.arizona.edu/v1/observations/daily/", "daily/") %>%
    httptest2::gsub_response("api.azmet.arizona.edu/v1/observations/hueto/", "hueto/") %>%
    httptest2::gsub_response("api.azmet.arizona.edu/v1/observations/hourly/", "hourly/") %>%
    httptest2::gsub_response("\\*", "default") #asterix is not valid dir name on all OS
  }
)
