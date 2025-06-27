# azmetr (development version)

- Added Elgin station ("az47") to station information
- Added `start_date` and `status` variables to `azmet-station-info.csv`
- Added Chino Valley station ("az45") to station information
- Added Test station ("az99") to station information

# azmetr 0.4.0

- Added function `az_lwdaily()` for downloading daily leaf wetness data, which now are available via the API
- Added function `az_lw15min()` for downloading 15-minute (a.k.a. "real-time") leaf wetness data, which now are available via the API
- Added function `az_15min()` for downloading 15-minute (a.k.a. "real-time") data, which now are available via the API

# azmetr 0.3.0

- `az_hourly()` now accepts dates for `start_date_time` and `end_date_time`
- Improved messages regarding what date/time ranges are being queried and returned by data retrieval functions.
- `az_hourly()` now returns data from the previous hour when `start_date_time` and `end_date_time` are not supplied rather than returning the previous day of hourly data.
- `azmet` is now much more verbose, printing messages about which data are requested and which data are returned.
- Added an option `"azmet.print_api_call"` which, when set to `TRUE` prints the HTTP request sent to the API—for debugging purposes.
- Fixed a bug that caused an error when data was requested from all stations but some stations didn't have data for all variables.
- Requests for data before January 1, 2021 now error, since these data are not on the AZMet API (yet).

# azmetr 0.2.1

- `az_daily()` and `az_hourly()` now print a warning if there is any missing data for the combination of dates and stations requested
- Transferred maintenance of package to Jeremy Weiss
- Timestamp for hourly and daily maximum two-minute sustained wind speeds, `wind_2min_timestamp` now appears in downloaded data
- Variable type for hourly and daily `wind_2min_timestamp` now is date-time instead of character with correct time zone, `tzone = "America/Phoenix"`
- Values for hourly `date_datetime` variable now have `tzone = "America/Phoenix"` assigned 
- The `station_info` dataset now includes elevation

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
