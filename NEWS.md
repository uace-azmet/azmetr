# azmetr (development version)

# azmetr 0.1.0

- functions now check if supplied `station_id` is valid and an active station before querying the API
- added `station_info` dataset with station names, IDs, and location.
- `az_daily()` and `az_hourly()` convert values like -999, -9999, etc. into `NA`s
- functions now return a 0x0 tibble when no data is returned by the API
- changed internal use of base R pipe (`|>`) to magrittr pipe (`%>%`) instead of requiring R 4.1 or later
- exports magrittr pipe (`%>%`) so it can be used when loading only `azmetr`
- You can now supply POSIXct or Date values to `start_date` and `end_date` arguments in addition to character ISO representations of date (e.g. YYYY-MM-DD or YYYY/MM/DD). You can supply POSIXct to `start_date_time` and `end_date_time`.  Additionally, you can use character with at least (but potentially more) precision to the hour. (e.g., YYYY-MM-DD HH:MM:SS now works and gets rounded down to the nearest hour).
- added vignettes
- fixed a bug where the wrong units were added to variables ending in `_mps` by `az_add_units()`

# azmetr 0.0.0.9000

* Functions for accessing hourly (`az_hourly()`) and daily (`az_daily()`) weather, and cumulative heat units / ETO (`az_heat()`) added.
* Added a `NEWS.md` file to track changes to the package.
