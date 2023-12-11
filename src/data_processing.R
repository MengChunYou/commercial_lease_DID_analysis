# data_processing.R

library(sf)
library(dplyr)
library(readxl)

# Polygons

## Read raw SHP data and filter study area polygons 
study_area_polygons <- 
  paste("data/raw/taiwan_village_polygons/",
        "VILLAGE_NLSC_121_1120317.shp", sep = "") %>% 
  st_read(.) %>% 
  filter(COUNTYNAME %in% c("臺北市"))

## Save the filtered polygons
save(study_area_polygons, 
     file = "data/processed/study_area_polygons.RData")

# Lease records

## Read lease records
lease <- rbind(
  read_xls("data/raw/lease_records/list_a1010101_1011231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1020101_1021231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1030101_1031231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1040101_1041231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1050101_1051231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1060101_1061231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1070101_1071231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1080101_1081231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1090101_1091231_c.xls", sheet = "不動產租賃"),
  read_xls("data/raw/lease_records/list_a1100101_1120131.xls", sheet = "不動產租賃"))

## Filter data

### Retain only lease records within the study area
lease_sf <- lease %>% 
  st_as_sf(coords = c("交易標的橫坐標", "交易標的縱坐標"), crs = 3826)
message(paste("number of accidents:", nrow(lease_sf)))

lease_sf <- lease_sf %>% 
  st_filter(st_union(study_area_polygons))
message(paste("number of accidents in study area:", nrow(lease_sf)))

### Retain only lease records happened between 2012 and 2022
lease_sf$租賃年月日 <- substr(lease_sf$租賃年月日, start = 1, stop = 3) %>% 
  as.numeric() %>% 
  add(1911) %>% 
  as.character() %>% 
  paste(substr(lease_sf$租賃年月日, start = 4, stop = 7), sep = "") %>% 
  as.Date(format = "%Y%m%d")

lease_sf <- lease_sf %>% arrange(租賃年月日) %>% 
  filter(租賃年月日 >= as.Date("20120101", format = "%Y%m%d")) %>% 
  filter(租賃年月日 <= as.Date("20221231", format = "%Y%m%d"))

## Feature engineering

### Create a dummy for commercial lease building type
data <- data %>% 
  mutate(`店面` = ifelse(`建物型態` == "店面(店鋪)", "店面", "非店面"))

## Save the filtered points
save(lease_sf, 
     file = "data/processed/processed_lease_records.RData")
