# EXAMPLE VCR USAGE: RUN AND DELETE ME

# foo <- function() crul::ok('https://httpbin.org/get')

foo <- function() {
  path <- c("v1", "observations", "daily")
  res <- httr::GET(base_url, path = path, httr::accept_json())
  res
}

test_that("foo httr", {
  vcr::use_cassette("testing", {
    x <- foo()
  })
  expect_true(x)
})
