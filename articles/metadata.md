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
#> Returning data from 2026-03-05 15:00

hourly %>% 
  select(-starts_with("meta_"), -starts_with("date_")) %>% 
  head()
#> # A tibble: 6 × 33
#>    dwpt  dwptF eto_azmet eto_azmet_in heatstress_cottonC heatstress_cottonF
#>    [°C] [degF]      [mm]         [in]               [°C]             [degF]
#> 1  -6.4   69.1       0.7         0.03               22.4               162.
#> 2  -6.4   69.1       0.8         0.03               22.5               162.
#> 3  -9.8   57.7       0.6         0.02               21.6               160.
#> 4  -3.8   77.2       0.7         0.03               23.2               165.
#> 5  -0.7   87.3       0.7         0.03               22.6               163.
#> 6 -12.7   48.4       0.8         0.03               19.5               153.
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
#>  1        16.2           692.      299.
#>  2        20.2           703.      299.
#>  3         8.64          692.      298.
#>  4        18.7           703.      300.
#>  5        21.6           706.      299.
#>  6        24.8           700       296.
#>  7        19.8           700       297.
#>  8        15.5           717.      295.
#>  9        15.1           669.      298.
#> 10        26.6           719.      300.
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
#> 14.5 [m/s]
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
