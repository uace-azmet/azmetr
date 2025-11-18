add_labels_heat <- function(heat) {
  attr(heat$meta_station_id, "label") <- "Station ID"
  attr(heat$meta_station_name, "label") <- "Station"
  attr(heat$chill_hours_0C_sum, "label") <- "Cumulative chill hours 0\u00b0C (h)"
  attr(heat$chill_hours_20C_sum, "label") <- "Cumulative chill hours 20\u00b0C (h)"
  attr(heat$chill_hours_32F_sum, "label") <- "Cumulative chill hours 32\u00b0F (h)"
  attr(heat$chill_hours_45F_sum, "label") <- "Cumulative chill hours 45\u00b0F (h)"
  attr(heat$chill_hours_68F_sum, "label") <- "Cumulative chill hours 68\u00b0F (h)"
  attr(heat$chill_hours_7C_sum, "label") <- "Cumulative chill hours 7\u00b0C (h)"
  attr(heat$datetime_last, "label") <- "Measurement timestamp of end date"
  attr(heat$eto_azmet_in, "label") <- "Reference evapotranspiration (in)"
  attr(heat$eto_azmet_in_sum, "label") <- "Cumulative reference evapotranspiration (in)"
  attr(heat$eto_pen_mon_in, "label") <- "Reference evapotranspiration (in)"
  attr(heat$eto_pen_mon_in_sum, "label") <- "Cumulative reference evapotranspiration (in)"
  attr(heat$heat_units_45F_sum, "label") <- "Cumulative heat units 86-45\u00b0F (degree-days)"
  attr(heat$heat_units_50F_sum, "label") <- "Cumulative heat units 86-50\u00b0F (degree-days)"
  attr(heat$heat_units_55F_sum, "label") <- "Cumulative heat units 86-55\u00b0F (degree-days)"
  attr(heat$heat_units_9455F_sum, "label") <- "Cumulative heat units 94-55\u00b0F (degree-days)"
  attr(heat$precip_total_in, "label") <- "Precipitation (in)"
  attr(heat$precip_total_in_sum, "label") <- "Cumulative precipitation (in)"

  heat
}
