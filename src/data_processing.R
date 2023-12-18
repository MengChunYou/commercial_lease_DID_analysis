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
message(paste("number of records:", nrow(lease_sf)))

lease_sf <- lease_sf %>% 
  st_filter(st_union(study_area_polygons))
message(paste("number of records in study area:", nrow(lease_sf)))

### Retain only lease records happened between 2020 and 2022
lease_sf$租賃年月日 <- substr(lease_sf$租賃年月日, start = 1, stop = 3) %>% 
  as.numeric() %>% 
  add(1911) %>% 
  as.character() %>% 
  paste(substr(lease_sf$租賃年月日, start = 4, stop = 7), sep = "") %>% 
  as.Date(format = "%Y%m%d")

lease_sf <- lease_sf %>% arrange(租賃年月日) %>% 
  filter(租賃年月日 >= as.Date("20200101", format = "%Y%m%d")) %>% 
  filter(租賃年月日 <= as.Date("20221231", format = "%Y%m%d"))
message(paste("number of records:", nrow(lease_sf)))

### Retain only specific types
# lease_sf <- lease_sf %>%
#   filter(`建物型態` %in% c("店面(店鋪)",
#                        "公寓(5樓含以下無電梯)",
#                        "華廈(10層含以下有電梯)",
#                        "套房(1房1廳1衛)",
#                        "住宅大樓(11層含以上有電梯)"))
# message(paste("number of records:", nrow(lease_sf)))

### Exclude records that only lease parking spaces and land
lease_sf <- lease_sf %>%
  filter((`交易標的` %>% grepl("建物", .)))
message(paste("number of records:", nrow(lease_sf)))

## Feature engineering

### Internal data

#### Create a dummy for commercial lease building type
lease_sf <- lease_sf %>% 
  mutate(`是否為店面` = ifelse(`建物型態` == "店面(店鋪)", TRUE, FALSE))

#### Village
lease_sf <- study_area_polygons %>% 
  select(TOWNNAME, VILLNAME) %>% 
  mutate(VILLNAME = paste(TOWNNAME, VILLNAME, sep = "")) %>% 
  select(VILLNAME) %>% 
  rename(`村里` = VILLNAME) %>% 
  st_join(lease_sf, ., left = T) 

#### Age of building
lease_sf$建築完成年月 <- substr(lease_sf$建築完成年月, start = 1, stop = 3) %>% 
  as.numeric() %>% 
  add(1911) %>% 
  as.character() %>% 
  paste(substr(lease_sf$建築完成年月, start = 4, stop = 7), sep = "") %>% 
  as.Date(format = "%Y%m%d")

lease_sf$`屋齡` <- as.numeric(lease_sf$`租賃年月日` - lease_sf$`建築完成年月`) / 365.25

#### Total floors
lease_sf$`總樓層數` <- lease_sf$`總樓層數` %>% as.numeric()

#### Rooms
lease_sf$`建物現況格局-房` <- lease_sf$`建物現況格局-房` %>% as.numeric()

#### Bathrooms
lease_sf$`建物現況格局-衛` <- lease_sf$`建物現況格局-衛` %>% as.numeric()

#### Is first floor
lease_sf <- lease_sf %>%
  mutate(`是否為一樓` = ifelse(`租賃層次` == "一層", TRUE, FALSE))

#### Year
lease_sf$`年` <- as.numeric(format(lease_sf$`租賃年月日`, "%Y"))

#### Month
lease_sf$`月` <- months(lease_sf$`租賃年月日`)

#### Year Month
lease_sf$`年月` <- as.yearmon(lease_sf$`租賃年月日`)

#### Difference in days from the announcement of level 3 alert
lease_sf$`天數差` <- as.numeric(lease_sf$`租賃年月日` - as.Date("20210515", format = "%Y%m%d"))

#### Difference in weeks from the announcement of level 3 alert
lease_sf$`週數差` <- floor(lease_sf$`天數差`/7) %>% 
  as.factor() %>% 
  relevel(ref = "-1")

#### Difference in months from the announcement of level 3 alert
lease_sf$`月數差` <- floor(lease_sf$`天數差`/30.44) %>% 
  as.factor() %>% 
  relevel(ref = "-1")

#### Difference in quarters from the announcement of level 3 alert
lease_sf$`季數差` <- floor(lease_sf$`天數差`/91.3125) %>% 
  as.factor() %>% 
  relevel(ref = "-1")

### External data (facilities)

#### Distance to school
lease_sf$`到學校距離` <- read.csv("data/raw/facilities/schools.csv") %>% 
  st_as_sf(., coords = c("lng", "lat"), crs = 4326) %>% 
  st_transform(crs = 3826) %>% 
  st_filter(study_area_polygons) %>% 
  st_distance(lease_sf, .) %>%
  apply(., 1, min)

#### Distance to TRTC stations
lease_sf$`到捷運站距離` <- read.csv("data/raw/facilities/TRTC_stations.csv", 
         fileEncoding = "Big5") %>% 
  st_as_sf(., coords = c("經度", "緯度"), crs = 4326) %>% 
  st_transform(crs = 3826) %>% 
  st_distance(lease_sf, .) %>%
  apply(., 1, min)

#### Distance to hospitals
lease_sf$`到醫療機構距離` <- read.csv("data/raw/facilities/hospitals.csv") %>% 
  st_as_sf(., coords = c("lng", "lat"), crs = 4326) %>% 
  st_transform(crs = 3826) %>% 
  st_distance(lease_sf, .) %>%
  apply(., 1, min)

## Rename columns
lease_sf <- lease_sf %>% 
  rename(`租賃面積` = `建物總面積(平方公尺)`) %>% 
  rename(`土地使用分區` = `都市土地使用分區`) %>% 
  rename(`單價` = `單價(元/平方公尺)`) %>% 
  rename(`房間數` = `建物現況格局-房`) %>% 
  rename(`衛浴數` = `建物現況格局-衛`)

## Select columns
lease_sf <- lease_sf %>% 
  select(`租賃年月日`, `年`, `月`, `年月`, `天數差`, `週數差`, `月數差`, `季數差`,
         `房間數`, `衛浴數`, `有無附傢俱`, `有無管理組織`,
         `是否為店面`, `村里`, 
         `單價`,
         `到學校距離`, `到捷運站距離`, `到醫療機構距離`,
         `屋齡`, `總樓層數`, `租賃面積`, `是否為一樓`,
         `土地使用分區`)

## Filter out missing data
lease_sf <- lease_sf %>% na.omit()
message(paste("number of records:", nrow(lease_sf)))

## Save the processed data
save(lease_sf, 
     file = "data/processed/processed_lease_records.RData")
