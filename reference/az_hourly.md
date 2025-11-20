# Retrieve Hourly Weather Data

Retrieves hourly weather data from the Arizona Meteorological Network
API. For a list of weather stations and their locations see
[station_info](https://uace-azmet.github.io/azmetr/reference/station_info.md),
or visit https://azmet.arizona.edu/about.

## Usage

``` r
az_hourly(station_id = NULL, start_date_time = NULL, end_date_time = NULL)
```

## Source

<https://azmet.arizona.edu/>

## Arguments

- station_id:

  station ID can be supplied as numeric vector (e.g.
  `station_id = c(8, 37)`) or as character vector with the prefix "az"
  and 2 digits (e.g. `station_id = c("az08", "az37")`) If left blank,
  data for all stations will be returned

- start_date_time:

  A length-1 vector of class POSIXct or character in YYYY-MM-DD HH
  format, in AZ time. Will be rounded **down** to the nearest hour if
  more precision is supplied. If only a date (YYYY-MM-DD) is supplied,
  data will be requested starting at 01:00:00 of that day

- end_date_time:

  A length-1 vector of class POSIXct or character in YYYY-MM-DD HH
  format, in AZ time. Will be rounded **down** to the nearest hour if
  more precision is supplied. If only a date (YYYY-MM-DD) is supplied,
  data will be requested through the *end* of that day (23:59:59).
  Defaults to the current date and time if left blank and
  `start_date_time` is specified.

## Value

A tibble. For units and other metadata, see
<https://azmet.arizona.edu/about>

## Details

If neither `start_date_time` nor `end_date_time` are supplied, the most
recent hour of data will be returned. If only `start_date_time` is
supplied, then `end_date_time` defaults to the current time. Supplying
only `end_date_time` will result in an error.

## Note

If `station_id` is supplied as a vector, multiple successive calls to
the API will be made. You may find better performance getting data for
all the stations by leaving `station_id` blank and subsetting the
resulting dataframe. Requests for data from all stations for more than
10-15 days may take considerable time.

## See also

[`az_15min()`](https://uace-azmet.github.io/azmetr/reference/az_15min.md),
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md),
[`az_heat()`](https://uace-azmet.github.io/azmetr/reference/az_heat.md),
[`az_lw15min()`](https://uace-azmet.github.io/azmetr/reference/az_lw15min.md),
[`az_lwdaily()`](https://uace-azmet.github.io/azmetr/reference/az_lwdaily.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Most recent data for all stations:
az_hourly()

# Specify stations:
az_hourly(station_id = c(1, 2))
az_hourly(station_id = c("az01", "az02"))

# Specify dates:
az_hourly(start_date_time = "2022-09-25 01")
az_hourly(start_date_time = "2022-09-25 01", end_date = "2022-09-25 20")
} # }
```
