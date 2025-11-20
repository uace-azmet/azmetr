# Basic usage of azmetr

``` r
library(azmetr)
library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union
```

## Retrieving the most recent day

To retrieve the the most recent day of data for all stations simply by
calling
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md)
or
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md)
without any arguments.
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md)
retrieves daily summary data and
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md)
retrieves hourly data.

``` r
daily <- az_daily()
#> Querying data from 2025-11-19
#> Returning data from 2025-11-19
hourly <- az_hourly()
#> Querying most recent hour of data ...
#> Warning in az_hourly(): You requested data through 2025-11-20 09:00:00 but only
#> data through 2025-11-20 08:00:00 were available
#> Returning data from 2025-11-20 08:00

head(daily)
#> # A tibble: 6 × 75
#>   meta_bat_volt_max meta_bat_volt_mean meta_bat_volt_min meta_needs_review
#>               <dbl>              <dbl>             <dbl>             <dbl>
#> 1              14.4               13.3              12.7                 0
#> 2              14.5               13.4              12.8                 0
#> 3              14.4               13.3              12.8                 0
#> 4              14.3               12.8              12.4                 0
#> 5              14.2               13.2              12.9                 0
#> 6              13.6               12.6              12.3                 0
#> # ℹ 71 more variables: meta_station_id <chr>, meta_station_name <chr>,
#> #   meta_version <dbl>, chill_hours_0C <dbl>, chill_hours_20C <dbl>,
#> #   chill_hours_32F <dbl>, chill_hours_45F <dbl>, chill_hours_68F <dbl>,
#> #   chill_hours_7C <dbl>, date_doy <dbl>, date_year <dbl>, datetime <date>,
#> #   dwpt_mean <dbl>, dwpt_meanF <dbl>, eto_azmet <dbl>, eto_azmet_in <dbl>,
#> #   eto_pen_mon <dbl>, eto_pen_mon_in <dbl>, heat_units_10C <dbl>,
#> #   heat_units_13C <dbl>, heat_units_3413C <dbl>, heat_units_45F <dbl>, …
head(hourly)
#> # A tibble: 6 × 42
#>   meta_bat_volt meta_needs_review meta_station_id meta_station_name meta_version
#>           <dbl>             <dbl> <chr>           <chr>                    <dbl>
#> 1          12.7                 0 az01            Tucson                       1
#> 2          13.1                 0 az02            Yuma Valley                  1
#> 3          13.1                 0 az04            Safford                      1
#> 4          12.4                 0 az05            Coolidge                     1
#> 5          12.9                 0 az06            Maricopa                     1
#> 6          12.4                 0 az07            Aguila                       1
#> # ℹ 37 more variables: date_datetime <dttm>, date_doy <dbl>, date_hour <chr>,
#> #   date_year <dbl>, dwpt <dbl>, dwptF <dbl>, eto_azmet <dbl>,
#> #   eto_azmet_in <dbl>, heatstress_cottonC <dbl>, heatstress_cottonF <dbl>,
#> #   precip_total <dbl>, precip_total_in <dbl>, relative_humidity <dbl>,
#> #   sol_rad_total <dbl>, sol_rad_total_ly <dbl>, temp_airC <dbl>,
#> #   temp_airF <dbl>, temp_soil_10cmC <dbl>, temp_soil_10cmF <dbl>,
#> #   temp_soil_50cmC <dbl>, temp_soil_50cmF <dbl>, vp_actual <dbl>, …
```

## Specifying date ranges

By supplying `start_date` to
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md)
or `start_date_time` to
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md)
you can retrieve data going back further in time.

``` r
last_date <- max(daily$datetime)
last_date
#> [1] "2025-11-19"
last_week <- last_date - lubridate::weeks(1)
wk <- az_daily(start_date = last_week)
#> Querying data from 2025-11-12 through 2025-11-19
#> Returning data from 2025-11-12 through 2025-11-19

range(wk$datetime)
#> [1] "2025-11-12" "2025-11-19"
```

``` r
last_datetime <- max(hourly$date_datetime)
last_datetime
#> [1] "2025-11-20 08:00:00 MST"
last_48h <- last_datetime - hours(48)
hr <- az_hourly(start_date_time = last_48h)
#> Querying data from 2025-11-18 08:00 through 2025-11-20 09:00
#> Warning in az_hourly(start_date_time = last_48h): You requested data through
#> 2025-11-20 09:00:00 but only data through 2025-11-20 08:00:00 were available
#> Returning data from 2025-11-18 08:00 through 2025-11-20 08:00

range(hr$date_datetime)
#> [1] "2025-11-18 08:00:00 MST" "2025-11-20 08:00:00 MST"
```

To specify an end date, use `end_date` or `end_date_time`. You must also
supply a start date if you supply an end date.

``` r
daily_range <- az_daily(start_date = "2022-01-01", end_date = "2022-01-05")
#> Querying data from 2022-01-01 through 2022-01-05
#> Returning data from 2022-01-01 through 2022-01-05
range(daily_range$datetime)
#> [1] "2022-01-01" "2022-01-05"
```

Note that the dates and datetimes can be supplied as character values in
year, month, day order or they can be supplied as Date or POSIXct
vectors. If the supplied date is more precise than the data, it will be
rounded down. For
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md)
datetimes will be rounded down to the nearest day and for
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md)
datetimes will be rounded down to the nearest hour.

``` r
char_daily <- az_daily(start_date = "2023-01-10 12:43:22", end_date = "2023-01-11 15:00:01")
#> Querying data from 2023-01-10 through 2023-01-11
#> Returning data from 2023-01-10 through 2023-01-11
range(char_daily$datetime)
#> [1] "2023-01-10" "2023-01-11"

char_hourly <- az_hourly(start_date = "2023-01-10 12:43:22", end_date = "2023-01-11 15:00:01")
#> Querying data from 2023-01-10 12:43 through 2023-01-11 15:00
#> Warning in az_hourly(start_date = "2023-01-10 12:43:22", end_date = "2023-01-11
#> 15:00:01"): You requested data through 2023-01-11 15:00:00 but only data
#> through 2023-01-11 14:00:00 were available
#> Returning data from 2023-01-10 13:00 through 2023-01-11 14:00
range(char_hourly$date_datetime)
#> [1] "2023-01-10 13:00:00 MST" "2023-01-11 14:00:00 MST"
```

## Filtering by station

Information on the stations available is contained in the `station_info`
dataset including station name, station ID, and location. As AZMet
includes its Test station (“az99”) in this information, retrieval of
data for all stations will include Test station data, which may be
erroneous. Subsetting such a retrieval to omit Test station data is
recommended.

``` r
station_info
#> # A tibble: 34 × 7
#>    meta_station_name meta_station_id latitude longitude elev_m start_date status
#>    <chr>             <chr>              <dbl>     <dbl>  <dbl> <date>     <chr> 
#>  1 Tucson            az01                32.3     -111.    714 2020-01-01 active
#>  2 Yuma Valley       az02                32.7     -115.     36 2020-01-01 active
#>  3 Safford           az04                32.8     -110.    903 2020-01-01 active
#>  4 Coolidge          az05                33.0     -112.    423 2020-01-01 active
#>  5 Maricopa          az06                33.1     -112.    362 2020-01-01 active
#>  6 Aguila            az07                33.9     -113.    657 2020-01-01 active
#>  7 Parker            az08                34.0     -114.     98 2020-01-01 active
#>  8 Bonita            az09                32.5     -110.   1349 2020-01-01 active
#>  9 Phoenix Greenway  az12                33.6     -112.    403 2020-01-01 active
#> 10 Yuma N.Gila       az14                32.8     -115.     43 2020-01-01 active
#> # ℹ 24 more rows
```

If you only need data for a subset of stations, you can supply
`station_id`. However, note that this will query the API once per
station due to limitations of how the API works. It may be faster to
just get data for all stations and subset it after since that only
queries the web API once and results in an identical dataset.

``` r
system.time(
  sub_wk <- az_daily(station_id = c(1, 2, 8), start_date = "2022-01-01", end_date = "2022-01-15")
)
#> Querying data from 2022-01-01 through 2022-01-15
#> Returning data from 2022-01-01 through 2022-01-15
#>    user  system elapsed 
#>   0.107   0.000   0.206
system.time(
  sub_wk2 <- subset(
    az_daily(start_date = "2022-01-01", end_date = "2022-01-15"),
    meta_station_id %in% c("az01", "az02", "az08")
  )
)
#> Querying data from 2022-01-01 through 2022-01-15
#> Returning data from 2022-01-01 through 2022-01-15
#>    user  system elapsed 
#>   0.394   0.000   0.759
all(sub_wk2 == sub_wk)
#> [1] NA
```
