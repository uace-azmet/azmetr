# Retrieve Accumulated Heat Units and Evapotranspiration

Retrieves accumulated heat units and reference evapotranspiration units
from the Arizona Meteorological Network API. By default, returned values
are cumulative since January 1 of the current year. For a list of
weather stations and their locations see
[station_info](https://uace-azmet.github.io/azmetr/reference/station_info.md),
or visit https://azmet.arizona.edu/about.

## Usage

``` r
az_heat(station_id = NULL, start_date = NULL, end_date = NULL)
```

## Source

<https://azmet.arizona.edu/>

## Arguments

- station_id:

  station ID can be supplied as numeric vector (e.g.
  `station_id = c(8, 37)`) or as character vector with the prefix "az"
  and 2 digits (e.g. `station_id = c("az08", "az37")`) If left blank
  data for all stations will be returned

- start_date:

  A length-1 vector of class Date, POSIXct, or character in YYYY-MM-DD
  format. Will be rounded **down** to the nearest day if more precision
  is supplied.

- end_date:

  A length-1 vector of class Date, POSIXct, or character in YYYY-MM-DD
  format. Will be rounded **down** to the nearest day if more precision
  is supplied. Defaults to the current date if left blank. If only an
  `end_date` is supplied, then data will be cumulative from the start of
  the year of `end_date`.

## Value

A tibble. For units and other metadata, see
<https://azmet.arizona.edu/about>

## Details

Unlike
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md),
only one row of data per station is returned, regardless of `start_date`
and `end_date`. However, the data returned is cumulative over the time
period specified by `start_date` and `end_date`.

## Note

If `station_id` is supplied as a vector, multiple successive calls to
the API will be made. You may find better performance getting data for
all the stations by leaving `station_id` blank and subsetting the
resulting dataframe.

## See also

[`az_15min()`](https://uace-azmet.github.io/azmetr/reference/az_15min.md),
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md),
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md),
[`az_lw15min()`](https://uace-azmet.github.io/azmetr/reference/az_lw15min.md),
[`az_lwdaily()`](https://uace-azmet.github.io/azmetr/reference/az_lwdaily.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Most recent data for all stations:
az_heat()

# Specify stations:
az_heat(station_id = c(1, 2))
az_heat(station_id = c("az01", "az02"))

# Specify dates:
## Cumulative since October 2022
az_heat(start_date = "2022-10-01")

## Cumulative from the first of the year through March
yr <- format(Sys.Date(), "%Y")

az_heat(end_date = paste(yr, "03", "31", sep = "-"))
} # }
```
