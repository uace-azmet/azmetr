yesterday <- lubridate::today(tzone = "America/Phoenix") - 1
last_month <- yesterday - lubridate::days(30)
with_mock_dir("heat_mocks", {

  test_that("numeric station_ids work", {
    res_station <- az_heat(station_id = 9)

    expect_s3_class(res_station, "data.frame")
  })

  test_that("az_heat() returns only one row per station even with dates", {
    start <- "2022-09-20"
    end <- "2022-09-27"
    res_start <- az_heat(station_id = 1, start_date = start, end_date = end)

    expect_equal(nrow(res_start), 1)
  })

  test_that("works with station_id as a vector", {
    res_2 <- az_heat(station_id = c(1, 2))

    expect_equal(unique(res_2$meta_station_id), c("az01", "az02"))
    expect_s3_class(res_2, "data.frame")
  })

  test_that("data is in correct format", {
    res_default <- az_heat()

    expect_s3_class(res_default, "data.frame")
    expect_equal(nrow(res_default), nrow(station_info))
    expect_type(res_default$meta_station_name, "character")
    expect_type(res_default$eto_pen_mon_in, "double")
    expect_s3_class(res_default$datetime_last, "Date")
  })

  test_that("no data is returned as 0x0 tibble", {
    res_nodata <-
      suppressWarnings(az_heat(start_date = "1980-01-01", end_date = "1980-01-02"))

    expect_true(nrow(res_nodata) == 0)
    expect_s3_class(res_nodata, "tbl_df")
  })

  test_that("start_date = NULL, end_date = NULL works", {
    expect_message(
      az_heat(station_id = 1),
      glue::glue("Querying data from {lubridate::floor_date(yesterday, 'year')} through {yesterday}")
    )
    expect_message(
      az_heat(station_id = 1),
      glue::glue("Returning data from {lubridate::floor_date(yesterday, 'year')} through {yesterday}")
    )
  })

  test_that("start_date = NULL, end_date specified works", {
    expect_message(
      az_heat(station_id = 1, end_date = yesterday),
      glue::glue("Querying data from {lubridate::floor_date(yesterday, 'year')} through {yesterday}")
    )
    expect_message(
      az_heat(station_id = 1, end_date = yesterday),
      glue::glue("Returning data from {lubridate::floor_date(yesterday, 'year')} through {yesterday}")
    )
    expect_message(
      az_heat(station_id = 1, end_date = "2022-02-01"),
      "Returning data from 2022-01-01 through 2022-02-01"
    )
  })

  test_that("start_date specified, end_date=NULL works", {
    expect_message(
      az_heat(station_id = 1, start_date = last_month),
      glue::glue("Querying data from {last_month} through {yesterday}")
    )
    expect_message(
      az_heat(station_id = 1, start_date = last_month),
      glue::glue("Returning data from {last_month} through {yesterday}")
    )
  })
})
