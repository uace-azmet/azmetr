## code to prepare `station_info` dataset goes here
library(tidyverse)
station_info <-
  read_csv("data-raw/azmet-station-info.csv") |>
  select(meta_station_name = name, meta_station_id = id, latitude, longitude, elev_m)

usethis::use_data(station_info, overwrite = TRUE)
