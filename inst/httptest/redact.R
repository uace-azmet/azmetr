## httptest2 isn't currently used, but if it is used for API mocking in the future, this will be helpful

##shortens file paths created by httptest2 so that R CMD check doesn't complain
# httptest2::set_redactor(
#   function (resp) {
#     resp %>%
#     httptest2::gsub_response("api.azmet.arizona.edu/v1/observations/", "") %>%
#     httptest2::gsub_response("\\*", "default") #asterix is not valid dir name on all OS
#   }
# )
