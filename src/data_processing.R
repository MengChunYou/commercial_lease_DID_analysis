# data_processing.R

library(sf)
library(dplyr)
library(readxl)
library(magrittr)
library(zoo)

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
lease_sf <- lease_sf %>% 
  mutate(`是否為店面` = ifelse(`建物型態` == "店面(店鋪)", TRUE, FALSE))

### Village
lease_sf <- study_area_polygons %>% 
  select(TOWNNAME, VILLNAME) %>% 
  mutate(VILLNAME = paste(TOWNNAME, VILLNAME, sep = "")) %>% 
  select(VILLNAME) %>% 
  rename(`村里` = VILLNAME) %>% 
  st_join(lease_sf, ., left = T) 

### Age of building
lease_sf$建築完成年月 <- substr(lease_sf$建築完成年月, start = 1, stop = 3) %>% 
  as.numeric() %>% 
  add(1911) %>% 
  as.character() %>% 
  paste(substr(lease_sf$建築完成年月, start = 4, stop = 7), sep = "") %>% 
  as.Date(format = "%Y%m%d")

lease_sf$`屋齡` <- as.numeric(lease_sf$`租賃年月日` - lease_sf$`建築完成年月`) / 365.25

### Total floors
lease_sf$`總樓層數` <- lease_sf$`總樓層數` %>% as.numeric()

### Is first floor
lease_sf <- lease_sf %>% 
  mutate(`是否為一樓` = ifelse(`租賃層次` == "一層", TRUE, FALSE))

### Has parking space
lease_sf <- lease_sf %>% 
  mutate(`有無車位` = ifelse(is.na(`車位類別`), FALSE, TRUE))

### Year
lease_sf$年 <- as.numeric(format(lease_sf$租賃年月日, "%Y"))

### Year Month
lease_sf$年月 <- as.yearmon(lease_sf$租賃年月日)

### Difference in days from the announcement of level 3 alert
lease_sf$t <- as.numeric(lease_sf$租賃年月日 - as.Date("20210515", format = "%Y%m%d"))

## Rename columns
lease_sf <- lease_sf %>% 
  rename(`租賃面積` = `建物總面積(平方公尺)`) %>% 
  rename(`房間數` = `建物現況格局-房`) %>% 
  rename(`衛浴數` = `建物現況格局-衛`) %>% 
  rename(`土地使用分區` = `都市土地使用分區`)

## Select columns
lease_sf <- lease_sf %>% 
  select(`租賃年月日`, `年`, `年月`, `t`, `是否為店面`, `村里`,
         # `到交流道路口距離`, `到學校距離`, `到醫院距離`, `到診所距離`, `到藥局距離`, `到賣場距離`, `到捷運站距離`, `到墓園距離`,
         `屋齡`, `總樓層數`, `租賃面積`, `房間數`, `衛浴數`, `是否為一樓`, `土地使用分區`, `有無車位`)

## Save the processed data
save(lease_sf, 
     file = "data/processed/processed_lease_records.RData")
