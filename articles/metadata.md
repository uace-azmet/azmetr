# Using azmetr with the units package

``` r

library(azmetr)
library(units)
#> udunits database from /usr/share/xml/udunits/udunits2.xml
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

## Adding units to data

You can add the correct units to data returned by
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md),
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md),
or
[`az_heat()`](https://uace-azmet.github.io/azmetr/reference/az_heat.md)
by passing the resulting tibble to
[`az_add_units()`](https://uace-azmet.github.io/azmetr/reference/az_add_units.md).

``` r

hourly <- 
  az_hourly() %>% 
  az_add_units() 
#> Querying most recent hour of data ...
#> Returning data from 2026-06-19 09:00

hourly %>% 
  select(-starts_with("meta_"), -starts_with("date_")) %>% 
  head()
#> # A tibble: 6 × 33
#>   dwpt  dwptF eto_azmet eto_azmet_in heatstress_cottonC heatstress_cottonF
#>   [°C] [degF]      [mm]         [in]               [°C]             [degF]
#> 1  5.3   107.       0.5         0.02               26.3               175.
#> 2 10.7   124.       0.4         0.02               26.9               177.
#> 3  4.8   105.       0.5         0.02               25.7               173.
#> 4  3.2   100.       0.6         0.02               26.2               175.
#> 5  3.9   102.       0.5         0.02               26.7               176.
#> 6  3.2   100.       0.5         0.02               25.5               172.
#> # ℹ 27 more variables: precip_total [mm], precip_total_in [in],
#> #   relative_humidity [%], sol_rad_total [MJ/m^2], sol_rad_total_ly [langleys],
#> #   temp_airC [°C], temp_airF [degF], temp_soil_10cmC [°C],
#> #   temp_soil_10cmF [degF], temp_soil_50cmC [°C], temp_soil_50cmF [degF],
#> #   vp_actual [kPa], vp_deficit [kPa], wind_2min_spd_max_mph [miles/h],
#> #   wind_2min_spd_max_mps [m/s], wind_2min_spd_mean_mph [miles/h],
#> #   wind_2min_spd_mean_mps [m/s], wind_2min_timestamp <dttm>, …
```

This requires that you have the `units` package installed and will
prompt you to do so if you don’t have it installed. It may also be
helpful to explicitly load the package with
[`library(units)`](https://r-quantities.github.io/units/) so that the
resulting tibble displays the units correctly.

## Using units columns

[`az_add_units()`](https://uace-azmet.github.io/azmetr/reference/az_add_units.md)
converts numeric vectors to those of class “units”. These units columns
behave differently than ordinary numeric vectors and have a few useful
properties. First, you can do unit conversion using
[`set_units()`](https://r-quantities.github.io/units/reference/units.html)
from the `units` package.

``` r

hourly %>% 
  transmute(wind_spd_kph = set_units(wind_spd_mps, "km/h"),
            sol_rad_total = set_units(sol_rad_total, "W h m-2"),
            temp_airK = set_units(temp_airF, "Kelvins"))
#> # A tibble: 35 × 3
#>    wind_spd_kph sol_rad_total temp_airK
#>          [km/h]     [W*h/m^2]       [K]
#>  1         5.04          567.      304.
#>  2         2.88          531.      304.
#>  3         6.12          600       303.
#>  4         7.2           606.      304.
#>  5         8.64          558.      305.
#>  6         7.56          583.      303.
#>  7        13.0           550       303.
#>  8         2.16          597.      301.
#>  9         3.96          556.      304.
#> 10         6.84          528.      304.
#> # ℹ 25 more rows
```

Second, it won’t allow you to do math where the units aren’t compatible.

``` r

hourly %>%  
  transmute(wind_rain = wind_spd_mps + precip_total)
#> Error in `transmute()`:
#> ℹ In argument: `wind_rain = wind_spd_mps + precip_total`.
#> Caused by error:
#> ! cannot convert mm into m/s
```

That also means that you generally cannot add or subtract unitless
constants.

``` r

## This will error:
# hourly$wind_spd_mps[1] + 10

## Must use:
hourly$wind_spd_mps[1] + set_units(10, "m/s")
#> 11.4 [m/s]
```

## Plotting with units

The `units` package works with `ggplot2` to automatically include units
in axis labels.

``` r

library(ggplot2)
ggplot(hourly, aes(x = wind_spd_mps, y = sol_rad_total)) +
  geom_point() +
  labs(x = "wind speed",
       y = "total solar radiation")
```

![](metadata_files/figure-html/unnamed-chunk-6-1.png)
