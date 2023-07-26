# azmetr (development version)

- Transfered maintainance of package to Jeremy Weiss
- Timestamp for hourly and daily maximum two-minute sustained wind speeds, `wind_2min_timestamp` now appears in downloaded data

# azmetr 0.2.0

- `azmetr` now uses the `httr2` package instead of `httr` for API requests. This change allowed for easier rate limiting
- There is now a rate limit of 4 requests per second to the API.  This shouldn't cause noticeable slowdowns except when using the `station_id` argument maybe
- `az_add_units()` now adds units to new `wind_2min_*` variables recently added to the API

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
