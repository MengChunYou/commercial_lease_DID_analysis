# regression_estimate.R

library(magrittr)
library(sf)
library(dplyr)

load("data/processed/processed_lease_records.Rdata")

# model 1 (full model)

## fit model
model_1 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `是否為店面` * `週數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + `有無車位` +
       `村里`, 
     data = .)

## write results
summary(model_1)$coefficient %>% as.data.frame() %>% 
  write.csv(., "outputs/regression_results/model_1_results.csv", fileEncoding = "utf8")

# model 2 

## fit model
model_2 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `是否為店面` * `週數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + `有無車位`, 
     data = .)

## write results
summary(model_2)$coefficient %>% as.data.frame() %>% 
  write.csv(., "outputs/regression_results/model_2_results.csv", fileEncoding = "utf8")
