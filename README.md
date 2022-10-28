
# azmetr

<!-- badges: start -->
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![R-CMD-check](https://github.com/cct-datascience/azmetr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cct-datascience/azmetr/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/cct-datascience/azmetr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/cct-datascience/azmetr?branch=main)
<!-- badges: end -->

The goal of azmetr is to provide programmatic access to the [Arizona Meteorological Network](https://ag.arizona.edu/azmet/) (AZMet) [API](https://app.swaggerhub.com/apis/mattjh/AZMetAPI/1.0#/) in R.

## Installation

You can install the development version of `azmetr` like so:

``` r
# install.packages("remotes")
remotes::install_github("cct-datascience/azmetr")
```

## Example

For the most recent day of data from all stations, run functions without any arguments:

``` r
library(azmetr)

az_daily()
az_hourly()
az_heat()
```

## Code of Conduct
  
  Please note that the `azmetr` project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
