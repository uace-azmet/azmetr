add_labels_lwdaily <- function(lwdaily) {
  attr(lwdaily$meta_needs_review, "label") <- "Data quality flag"
  attr(lwdaily$meta_station_id, "label") <- "Station ID"
  attr(lwdaily$meta_station_name, "label") <- "Station"
  # attr(lwdaily$meta_version, "label") <- 
  attr(lwdaily$date, "label") <- "Date"
  attr(lwdaily$date_doy, "label") <- "Day of year"
  attr(lwdaily$date_year, "label") <- "Year"
  attr(lwdaily$datetime, "label") <- "Datetime" # Why is this column even in the output?
  attr(lwdaily$dwpt_30cm_max, "label") <- "Max. dewpoint at 30cm height (\u00b0C)"
  attr(lwdaily$dwpt_30cm_mean, "label") <- "Avg. dewpoint at 30cm height (\u00b0C)"
  attr(lwdaily$dwpt_30cm_min, "label") <- "Min. dewpoint at 30cm height (\u00b0C)"
  
  # Not sure about these
  # attr(lwdaily$lw1_total_con_mins, "label") <- ""
  attr(lwdaily$lw1_total_dry_mins, "label") <- "Total minutes dry"
  attr(lwdaily$lw1_total_wet_mins, "label") <- "Total minutes wet"
  # attr(lwdaily$lw2_total_con_mins, "label") <- ""
  attr(lwdaily$lw2_total_dry_mins, "label") <- "Total minutes dry"
  attr(lwdaily$lw2_total_wet_mins, "label") <- "Total minutes wet"
  
  attr(lwdaily$relative_humidity_30cm_max, "label") <- "Max. RH at 30cm height (%)"
  attr(lwdaily$relative_humidity_30cm_mean, "label") <- "Avg. RH at 30cm height (%)"
  attr(lwdaily$relative_humidity_30cm_min, "label") <- "Min. RH at 30cm height (%)"
  attr(lwdaily$temp_air_30cm_maxC, "label") <- "Max. air temperature at 30cm height (\u00b0C)"
  attr(lwdaily$temp_air_30cm_meanC, "label") <- "Avg. air temperature at 30cm height (\u00b0C)"
  attr(lwdaily$temp_air_30cm_minC, "label") <- "Min. air temperature at 30cm height (\u00b0C)"
  
  lwdaily
}