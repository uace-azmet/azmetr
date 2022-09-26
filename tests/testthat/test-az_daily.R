test_that("all stations return data", {
  skip_if_offline()
  skip_if_not(ping_service())
  expect_equal(nrow(az_daily()), 28)
})
