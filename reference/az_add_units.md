# Assign units using the `units` package

Assigns correct units to the output of
[`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md),
[`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md),
and
[`az_heat()`](https://uace-azmet.github.io/azmetr/reference/az_heat.md)
using the `units` package.

## Usage

``` r
az_add_units(x)
```

## Arguments

- x:

  A tibble output by
  [`az_hourly()`](https://uace-azmet.github.io/azmetr/reference/az_hourly.md),
  [`az_daily()`](https://uace-azmet.github.io/azmetr/reference/az_daily.md),
  or
  [`az_heat()`](https://uace-azmet.github.io/azmetr/reference/az_heat.md)

## Value

A tibble with columns of class "units"

## Examples

``` r
if (FALSE) { # \dontrun{
daily <- az_daily()

daily_units <-
  az_add_units(daily)

#unit conversions with `units::set_units()`
daily_units$sol_rad_total %>% units::set_units("kW h m-2")

#units carry through calculations
climatic_balance <-
  daily_units$precip_total_mm - daily_units$eto_pen_mon
climatic_balance
} # }
```
