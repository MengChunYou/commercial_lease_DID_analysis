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

lease_sf <- lease_sf %>% 
  mutate(`是否為店面` = factor(`是否為店面`, levels = c(T, F)))

## Variable summary for 2 groups
variable_summary <- lease_sf %>% st_drop_geometry() %>% 
  group_by(`是否為店面`) %>% 
  summarise(mean(`房間數`),
            sd(`房間數`),
            mean(`衛浴數`),
            sd(`衛浴數`),
            mean(`有無附傢俱` == "有"),
            `有無附傢俱sd` = sqrt(
              mean(`有無附傢俱` == "有")*(1 - mean(`有無附傢俱` == "有"))/(length(`有無附傢俱`) - 1)
            ), 
            mean(`有無管理組織` == "有"),
            `有無管理組織sd` = sqrt(
              mean(`有無管理組織` == "有")*(1 - mean(`有無管理組織` == "有"))/(length(`有無管理組織`) - 1)
            ), 
            mean(`到學校距離`),
            sd(`到學校距離`),
            mean(`到捷運站距離`),
            sd(`到捷運站距離`),
            mean(`到醫療機構距離`),
            sd(`到醫療機構距離`),
            mean(`屋齡`),
            sd(`屋齡`),
            mean(`總樓層數`),
            sd(`總樓層數`),
            mean(`租賃面積`),
            sd(`租賃面積`),
            mean(`是否為一樓`),
            `是否為一樓sd` = sqrt(
              mean(`是否為一樓`)*(1 - mean(`是否為一樓`))/(length(`是否為一樓`) - 1)
            ),
            length(`租賃年月日`)
  ) %>% t() %>% as.data.frame() %>% .[-1, ]
colnames(variable_summary) = c("Treatment", "Comparison")
variable_summary <- variable_summary %>% 
  mutate(Treatment = as.numeric(Treatment)) %>% 
  mutate(Comparison = as.numeric(Comparison)) %>% 
  mutate(Difference = ifelse(
    grepl("mean", rownames(.)), 
    round((`Treatment` - `Comparison`), 3),
    ""
  )
  ) %>% 
  mutate(Treatment = round(Treatment, 3)) %>% 
  mutate(Comparison = round(Comparison, 3))

variable_summary[2*c(1:11),3] <- c(
  t.test(`房間數`~`是否為店面`, lease_sf)$stderr,
  t.test(`衛浴數`~`是否為店面`, lease_sf)$stderr,
  sqrt(
    mean(lease_sf$`有無附傢俱`=="有")*(1-mean(lease_sf$`有無附傢俱`=="有"))*
      (1/sum(lease_sf$`是否為店面`=="TRUE") + 1/sum(lease_sf$`是否為店面`=="FALSE"))
  ),
  sqrt(
    mean(lease_sf$`有無管理組織`=="有")*(1-mean(lease_sf$`有無管理組織`=="有"))*
      (1/sum(lease_sf$`是否為店面`=="TRUE") + 1/sum(lease_sf$`是否為店面`=="FALSE"))
  ),
  t.test(`到學校距離`~`是否為店面`, lease_sf)$stderr,
  t.test(`到捷運站距離`~`是否為店面`, lease_sf)$stderr,
  t.test(`到醫療機構距離`~`是否為店面`, lease_sf)$stderr,
  t.test(`屋齡`~`是否為店面`, lease_sf)$stderr,
  t.test(`總樓層數`~`是否為店面`, lease_sf)$stderr,
  t.test(`租賃面積`~`是否為店面`, lease_sf)$stderr,
  sqrt(
    mean(lease_sf$`是否為一樓`)*(1-mean(lease_sf$`是否為一樓`))*
      (1/sum(lease_sf$`是否為店面`=="TRUE") + 1/sum(lease_sf$`是否為店面`=="FALSE"))
  )
) %>% round(3)

variable_summary[2*c(1:11),3] <- c(
  t.test(`房間數`~`是否為店面`, lease_sf)$p.value,
  t.test(`衛浴數`~`是否為店面`, lease_sf)$p.value,
  sqrt(
    mean(lease_sf$`有無附傢俱`=="有")*(1-mean(lease_sf$`有無附傢俱`=="有"))*
      (1/sum(lease_sf$`是否為店面`=="TRUE") + 1/sum(lease_sf$`是否為店面`=="FALSE"))
  ),
  sqrt(
    mean(lease_sf$`有無管理組織`=="有")*(1-mean(lease_sf$`有無管理組織`=="有"))*
      (1/sum(lease_sf$`是否為店面`=="TRUE") + 1/sum(lease_sf$`是否為店面`=="FALSE"))
  ),
  t.test(`到學校距離`~`是否為店面`, lease_sf)$stderr,
  t.test(`到捷運站距離`~`是否為店面`, lease_sf)$stderr,
  t.test(`到醫療機構距離`~`是否為店面`, lease_sf)$stderr,
  t.test(`屋齡`~`是否為店面`, lease_sf)$stderr,
  t.test(`總樓層數`~`是否為店面`, lease_sf)$stderr,
  t.test(`租賃面積`~`是否為店面`, lease_sf)$stderr,
  sqrt(
    mean(lease_sf$`是否為一樓`)*(1-mean(lease_sf$`是否為一樓`))*
      (1/sum(lease_sf$`是否為店面`=="TRUE") + 1/sum(lease_sf$`是否為店面`=="FALSE"))
  )
) %>% round(3)

variable_summary %>% 
  mutate(variable = c("房間數", "",
                      "衛浴數", "",
                      "有無附傢俱", "",
                      "有無管理組織", "",
                      "到學校距離", "",
                      "到捷運站距離", "",
                      "到醫療機構距離", "",
                      "屋齡", "",
                      "總樓層數", "",
                      "租賃面積", "",
                      "是否為一樓", "",
                      "# of buildings"), .before = "Treatment") %>% 
  write.csv("outputs/descriptive_statistics/variable_summary_for_2_groups.csv", row.names = F)

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
  labs(title = "", x = "年月", y = "平均單價(元/平方公尺)") +
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
  labs(title = "", x = "季數差", y = "平均單價(元/平方公尺)") +
  theme_bw() +
  theme(text = element_text(family = "JhengHei", size = 20),
        plot.title = element_text(hjust = 0.5, face = "bold"))

print(p)

#### Close the PNG device
dev.off()