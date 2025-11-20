# Retrieve Daily Weather Data from AZMET

Retrieves daily data from the Arizona Meteorological Network API. For a
list of weather stations and their locations see
[station_info](https://uace-azmet.github.io/azmetr/reference/station_info.md),
or visit https://azmet.arizona.edu/about.

## Usage

``` r
az_daily(station_id = NULL, start_date = NULL, end_date = NULL)
```

## Source

<https://azmet.arizona.edu/>

## Arguments

- station_id:

  station ID can be supplied as numeric vector (e.g.
  `station_id = c(8, 37)`) or as character vector with the prefix "az"
  and two digits (e.g. `station_id = c("az08", "az37")`). If left blank,
  data for all stations will be returned.

- start_date:

  A length-1 vector of class Date, POSIXct, or character in YYYY-MM-DD
  format. Will be rounded **down** to the nearest day if more precision
  is supplied. Defaults to the day before the current date (i.e., the
  most recent complete day) if left blank.

- end_date:

  A length-1 vector of class Date, POSIXct, or character in YYYY-MM-DD
  format. Will be rounded **down** to the nearest day if more precision
  is supplied. Defaults to the day before the current date (i.e., the
  most recent complete day) if left blank.

## Value

A tibble. For units and other metadata, see
<https://azmet.arizona.edu/about>

## Details

If neither `start_date` nor `end_date` are supplied, the most recent day
of data will be returned. If only `start_date` is supplied, then the end
date defaults to the day before the current date (i.e., the most recent
complete day). Supplying only `end_date` will result in an error.

## Note

If `station_id` is supplied as a vector, multiple successive calls to
the API will be made. You may find better performance getting data for
all the stations by leaving `station_id` blank and subsetting the
resulting dataframe. Requests for data from all stations for more than
6-12 months may take considerable time.

## See also

[`az_15min()`](https://uace-azmet.github.io/azmetr/reference/az_15min.md),
[`az_heat()`](https://uace-azmet.github.io/azmetr/reference/az_heat.md),
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md),
[`az_lw15min()`](https://uace-azmet.github.io/azmetr/reference/az_lw15min.md),
[`az_lwdaily()`](https://uace-azmet.github.io/azmetr/reference/az_lwdaily.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Most recent data for all stations:
az_daily()

# Specify stations:
az_daily(station_id = c(1, 2))
az_daily(station_id = c("az01", "az02"))

# Specify dates:
az_daily(start_date = "2022-09-25")
az_daily(start_date = "2022-09-25", end_date = "2022-09-26")
} # }
```
