# regression_estimate.R

library(magrittr)
library(sf)
library(dplyr)

load("data/processed/processed_lease_records.Rdata")

# model 1 (weekly)

## fit model
my_model <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `是否為店面` * `週數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + `有無車位` +
       `村里`, 
     data = .)

## write results
result_df <- data.frame(
  coef = names(my_model$coefficients)
)
result_df <- summary(my_model)$coefficients %>% 
  as.data.frame() %>% 
  mutate(coef = rownames(.)) %>% 
  left_join(result_df, ., by = join_by(coef))
result_df <- confint(my_model) %>% 
  as.data.frame() %>% 
  mutate(coef = rownames(.)) %>% 
  left_join(result_df, ., by = join_by(coef))

write.csv(result_df, 
          "outputs/regression_results/model_1_results.csv", 
          fileEncoding = "utf8", row.names = F)

# model 2 (monthly)

## fit model
my_model <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `是否為店面` * `月數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + `有無車位` +
       `村里`, 
     data = .)

## write results
result_df <- data.frame(
  coef = names(my_model$coefficients)
)
result_df <- summary(my_model)$coefficients %>% 
  as.data.frame() %>% 
  mutate(coef = rownames(.)) %>% 
  left_join(result_df, ., by = join_by(coef))
result_df <- confint(my_model) %>% 
  as.data.frame() %>% 
  mutate(coef = rownames(.)) %>% 
  left_join(result_df, ., by = join_by(coef))

write.csv(result_df, 
          "outputs/regression_results/model_2_results.csv", 
          fileEncoding = "utf8", row.names = F)

# model 3 (quarterly)

## fit model
my_model <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `是否為店面` * `季數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + `有無車位` +
       `村里`, 
     data = .)

## write results
result_df <- data.frame(
  coef = names(my_model$coefficients)
)
result_df <- summary(my_model)$coefficients %>% 
  as.data.frame() %>% 
  mutate(coef = rownames(.)) %>% 
  left_join(result_df, ., by = join_by(coef))
result_df <- confint(my_model) %>% 
  as.data.frame() %>% 
  mutate(coef = rownames(.)) %>% 
  left_join(result_df, ., by = join_by(coef))

write.csv(result_df, 
          "outputs/regression_results/model_3_results.csv", 
          fileEncoding = "utf8", row.names = F)