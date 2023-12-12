# regression_estimate.R

library(magrittr)
library(sf)
library(dplyr)

load("data/processed/processed_lease_records.Rdata")

write_result <- function(lm_result, output_name) {
  
  # This is a function to write result of estimated coefficients in to csv.
  result_df <- data.frame(coef = names(lm_result$coefficients))
  result_df <- summary(lm_result)$coefficients %>% 
    as.data.frame() %>% 
    mutate(coef = rownames(.)) %>% 
    left_join(result_df, ., by = join_by(coef))
  result_df <- confint(lm_result) %>% 
    as.data.frame() %>% 
    mutate(coef = rownames(.)) %>% 
    left_join(result_df, ., by = join_by(coef))
  colnames(result_df) <- c("coef", "estimate", "se", "t_value", "p_value", "lower", "upper")
  write.csv(result_df, 
            paste("outputs/regression_results/", output_name, sep = ""), 
            fileEncoding = "utf8", row.names = F)
}

# model 1 (weekly)
model_1 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `月` + `是否為店面` * `週數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + 
       `村里`, 
     data = .)

# model 2 (monthly)
model_2 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `月` + `是否為店面` * `月數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + 
       `村里`, 
     data = .)

# model 3 (quarterly)
model_3 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `月` + `是否為店面` * `季數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + 
       `村里`, 
     data = .)

# model 4 (weekly)
model_4 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `月` + `是否為店面` * `週數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區`, 
     data = .)

# model 5 (monthly)
model_5 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `月` + `是否為店面` * `月數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區`, 
     data = .)

# model 6 (quarterly)
model_6 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `月` + `是否為店面` * `季數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區`, 
     data = .)

# model 7 (weekly)
model_7 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `是否為店面` * `週數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + 
       `村里`, 
     data = .)

# model 8 (monthly)
model_8 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `是否為店面` * `月數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + 
       `村里`, 
     data = .)

# model 9 (quarterly)
model_9 <- lease_sf %>% st_drop_geometry() %>% 
  lm(`單價`~ 0 + `是否為店面` * `季數差` + 
       `到學校距離` + `到捷運站距離` + `屋齡` +
       `總樓層數` + `租賃面積` + `是否為一樓` + `土地使用分區` + 
       `村里`, 
     data = .)

# write results
write_result(model_1, "model_1_results.csv")
write_result(model_2, "model_2_results.csv")
write_result(model_3, "model_3_results.csv")
write_result(model_4, "model_4_results.csv")
write_result(model_5, "model_5_results.csv")
write_result(model_6, "model_6_results.csv")
write_result(model_7, "model_7_results.csv")
write_result(model_8, "model_8_results.csv")
write_result(model_9, "model_9_results.csv")