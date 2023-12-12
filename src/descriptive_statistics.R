# descriptive_statistics.R

library(sf)
library(tmap)
library(dplyr)
library(ggplot2)

# set font family
windowsFonts(JhengHei = windowsFont(family = "Microsoft JhengHei"))

# Load data
load("data/processed/study_area_polygons.RData")
load("data/processed/processed_lease_records.RData")

## Variable summary for 2 groups

lease_sf %>% st_drop_geometry() %>% 
  group_by(`是否為店面`) %>% 
  summarise(`屋齡` = mean(`屋齡`, na.rm = T),
            `總樓層數` = mean(`總樓層數`, na.rm = T),
            `租賃面積` = mean(`租賃面積`),
            `到學校距離` = mean(`到學校距離`),
            `到捷運站距離` = mean(`到捷運站距離`))

## Lease records map

village <- study_area_polygons %>% 
  tm_shape() +
  tm_polygons(border.col = "gray90", alpha = 0)

town <- study_area_polygons %>% group_by(TOWNID) %>% summarise() %>% 
  tm_shape() +
  tm_polygons(border.col = "gray70", alpha = 0)

lease <- lease_sf %>% 
  tm_shape() +
  tm_dots(col = "blue", alpha = 0.01, size = 0.005)

### Open a PNG device for graphics output
open_png("outputs/descriptive_statistics/lease_records_map.png")

### Create Plot
p <- village + town + lease + 
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

print(p)

### Close the PNG device
dev.off()

## time series

### weekly

#### Open a PNG device for graphics output
open_png("outputs/descriptive_statistics/average_unit_prices_time_series/weekly.png")

#### Create Plot
p <- lease_sf %>% st_drop_geometry() %>% 
  group_by(`週數差`, `是否為店面`) %>%
  summarise(`單價` = mean(`單價`, na.rm = TRUE)) %>%
  ggplot() +
  geom_line(aes(x = `週數差` %>% as.character() %>% as.numeric(), 
                y = `單價`, 
                group = `是否為店面`, color = `是否為店面`), 
            size = 1) +
  geom_vline(xintercept = -1, col = "darkgray", lty = 2, size = 1) +
  labs(title = "不動產租賃平均單價時間序列", x = "週數差", y = "平均單價(元/平方公尺)") +
  theme_bw() +
  theme(text = element_text(family = "JhengHei", size = 20),
        plot.title = element_text(hjust = 0.5, face = "bold"))

print(p)

#### Close the PNG device
dev.off()

### monthly

#### Open a PNG device for graphics output
open_png("outputs/descriptive_statistics/average_unit_prices_time_series/monthly.png")

#### Create Plot
p <- lease_sf %>% st_drop_geometry() %>% 
  group_by(`年月`, `是否為店面`) %>%
  summarise(`單價` = mean(`單價`, na.rm = TRUE)) %>%
  ggplot() +
  geom_line(aes(x = `年月`, y = `單價`, 
                group = `是否為店面`, color = `是否為店面`), 
            size = 1) +
  geom_vline(xintercept = as.Date("20210401", format = "%Y%m%d") %>% as.yearmon(), 
             col = "darkgray", lty = 2, size = 1) +
  labs(title = "不動產租賃平均單價時間序列", x = "年月", y = "平均單價(元/平方公尺)") +
  theme_bw() +
  scale_x_yearmon(format = "%Y-%m") +
  theme(text = element_text(family = "JhengHei", size = 20),
        plot.title = element_text(hjust = 0.5, face = "bold"))

print(p)

#### Close the PNG device
dev.off()

### quarterly

#### Open a PNG device for graphics output
open_png("outputs/descriptive_statistics/average_unit_prices_time_series/quarterly.png")

#### Create Plot
p <- lease_sf %>% st_drop_geometry() %>% 
  group_by(`季數差`, `是否為店面`) %>%
  summarise(`單價` = mean(`單價`, na.rm = TRUE)) %>%
  ggplot() +
  geom_line(aes(x = `季數差` %>% as.character() %>% as.numeric(), 
                y = `單價`, 
                group = `是否為店面`, color = `是否為店面`), 
            size = 1) +
  geom_vline(xintercept = -1, col = "darkgray", lty = 2, size = 1) +
  labs(title = "不動產租賃平均單價時間序列", x = "季數差", y = "平均單價(元/平方公尺)") +
  theme_bw() +
  theme(text = element_text(family = "JhengHei", size = 20),
        plot.title = element_text(hjust = 0.5, face = "bold"))

print(p)

#### Close the PNG device
dev.off()