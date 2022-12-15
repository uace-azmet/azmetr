# azmetr (development version)

- functions now check if supplied `station_id` is valid and an active station before querying the API
- added `station_info` dataset with station names, IDs, and location.
- `az_daily()` and `az_hourly()` convert values like -999, -9999, etc. into `NA`s
- functions now return a 0x0 tibble when no data is returned by the API
- changed internal use of base R pipe (`|>`) to tidyverse pipe (`%>%`) instead of requiring R 4.1 or later

# azmetr 0.0.0.9000

* Functions for accessing hourly (`az_hourly()`) and daily (`az_daily()`) weather, and cumulative heat units / ETO (`az_heat()`) added.
* Added a `NEWS.md` file to track changes to the package.
