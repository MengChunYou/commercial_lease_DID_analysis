# descriptive_statistics.R

library(sf)
library(tmap)
library(dplyr)
library(ggplot2)

# set font family
windowsFonts(JhengHei = windowsFont(family = "Microsoft JhengHei"))

## Lease records map

### Load data
load("data/processed/study_area_polygons.RData")
load("data/processed/processed_lease_records.RData")

### Plot map
village <- study_area_polygons %>% 
  tm_shape() +
  tm_polygons(border.col = "gray90", alpha = 0)

town <- study_area_polygons %>% group_by(TOWNID) %>% summarise() %>% 
  tm_shape() +
  tm_polygons(border.col = "gray70", alpha = 0)

lease <- lease_sf %>% 
  tm_shape() +
  tm_dots(col = "blue", alpha = 0.01, size = 0.005)

#### Open a PNG device for graphics output
open_png("outputs/descriptive_statistics/lease_records_map.png")

#### Create Plot
village + town + lease + 
  tm_layout(frame = F, fontfamily = "JhengHei",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.position = c("left", "bottom"),
            legend.title.fontface = "bold") +
  tm_add_legend("symbol",
                col = "blue", alpha = 0.3, size = 0.5,
                border.alpha = 0,
                labels = c("不動產租賃點位"),
                title = "圖例", ) +
  tm_add_legend("line",
                col = c("gray90", "gray70"),
                labels = c("村里界", "鄉鎮市區界"))

#### Close the PNG device
dev.off()
