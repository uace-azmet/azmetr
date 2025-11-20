# Retrieve 15-minute Leaf Wetness Data from AZMet

Retrieves 15-minute leaf-wetness data from the AZMet (Arizona
Meteorological Network) API. Currently, these data only are available
from weather stations in the Yuma area. For a list of stations and their
locations see
[station_info](https://uace-azmet.github.io/azmetr/reference/station_info.md),
or visit https://azmet.arizona.edu/about.

## Usage

``` r
az_lw15min(station_id = NULL, start_date_time = NULL, end_date_time = NULL)
```

## Source

<https://azmet.arizona.edu/>

## Arguments

- station_id:

  Station ID can be supplied as numeric vector (e.g.
  `station_id = c(8, 37)`) or as character vector with the prefix "az"
  and two digits (e.g. `station_id = c("az08", "az37")`). If left blank,
  data for all stations will be returned.

- start_date_time:

  A length-1 vector of class POSIXct or character in YYYY-MM-DD HH:MM:SS
  format, in AZ time. If only a date (YYYY-MM-DD) is supplied, data will
  be requested starting at 00:00:01 of that day.

- end_date_time:

  A length-1 vector of class POSIXct or character in YYYY-MM-DD HH:MM:SS
  format, in AZ time. If only a date (YYYY-MM-DD) is supplied, data will
  be requested through the *end* of that day (23:59:59). Defaults to the
  current date and time if left blank and `start_date_time` is
  specified.

## Value

A tibble. For units and other metadata, see
<https://azmet.arizona.edu/about>

## Details

If neither `start_date_time` nor `end_date_time` are supplied, the most
recent datetime of data will be returned. If only `start_date_time` is
supplied, then `end_date_time` defaults to the current time. Supplying
only `end_date_time` will result in an error.

## Note

If `station_id` is supplied as a vector, multiple successive calls to
the API will be made. You may find better performance getting data for
all the stations by leaving `station_id` blank and subsetting the
resulting dataframe. Only the most recent 48 hours of 15-minute data are
stored in the AZMet API.

## See also

[`az_15min()`](https://uace-azmet.github.io/azmetr/reference/az_15min.md),
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md),
[`az_heat()`](https://uace-azmet.github.io/azmetr/reference/az_heat.md),
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md),
[`az_lwdaily()`](https://uace-azmet.github.io/azmetr/reference/az_lwdaily.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Most recent 15-minute leaf-wetness data for all stations:
az_lw15min()

# Specify stations:
az_lw15min(station_id = c(1, 2))
az_lw15min(station_id = c("az01", "az02"))

# Specify dates:
az_lw15min(start_date_time = "2022-09-25 01:00:00")
az_lw15min(start_date_time = "2022-09-25 01:00:00", end_date_time = "2022-09-25 07:00:00")
} # }
```
