# regression_estimate.R

library(magrittr)
library(sf)
library(dplyr)

load("data/processed/processed_lease_records.Rdata")

write_result <- function(lm_result, output_name) {
  
  # This is a function to write result of estimated coefficients in to csv.
  result_df <- data.frame(coef = names(lm_result$coefficients))
  print(summary(lm_result)$coefficients)
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

formulas <- list()

# model 1
formulas <- (
  `單價`~ 0 + `月` + `是否為店面` * `月數差` + 
  `到學校距離` + `到捷運站距離` + `到醫療機構距離` +
  I(`到學校距離`^2) + I(`到捷運站距離`^2) + I(`到醫療機構距離`^2) +
  `屋齡` + `房間數` +`衛浴數` + `總樓層數` + `租賃面積` + 
  `是否為一樓` + `土地使用分區` + `有無附傢俱` + `有無管理組織` +
  `村里`
  ) %>% append(formulas, .)

# model 2
formulas <- (
  `單價`~ 0 + `月` + `是否為店面` * `季數差` + 
    `到學校距離` + `到捷運站距離` + `到醫療機構距離` +
    I(`到學校距離`^2) + I(`到捷運站距離`^2) + I(`到醫療機構距離`^2) +
    `屋齡` + `房間數` +`衛浴數` + `總樓層數` + `租賃面積` + 
    `是否為一樓` + `土地使用分區` + `有無附傢俱` + `有無管理組織` +
    `村里`
) %>% append(formulas, .)

# model 3
formulas <- (
  `單價`~ 0 + `月` + `是否為店面` * `月數差` + 
    `到學校距離` + `到捷運站距離` + `到醫療機構距離` +
    I(`到學校距離`^2) + I(`到捷運站距離`^2) + I(`到醫療機構距離`^2) +
    `屋齡` + `房間數` +`衛浴數` + `總樓層數` + `租賃面積` + 
    `是否為一樓` + `土地使用分區` + `有無附傢俱` + `有無管理組織`
) %>% append(formulas, .)

# model 4
formulas <- (
  `單價`~ 0 + `月` + `是否為店面` * `季數差` + 
    `到學校距離` + `到捷運站距離` + `到醫療機構距離` +
    I(`到學校距離`^2) + I(`到捷運站距離`^2) + I(`到醫療機構距離`^2) +
    `屋齡` + `房間數` +`衛浴數` + `總樓層數` + `租賃面積` + 
    `是否為一樓` + `土地使用分區` + `有無附傢俱` + `有無管理組織`
) %>% append(formulas, .)

# model 5
formulas <- (
  `單價`~ 0 + `是否為店面` * `月數差` + 
    `到學校距離` + `到捷運站距離` + `到醫療機構距離` +
    I(`到學校距離`^2) + I(`到捷運站距離`^2) + I(`到醫療機構距離`^2) +
    `屋齡` + `房間數` +`衛浴數` + `總樓層數` + `租賃面積` + 
    `是否為一樓` + `土地使用分區` + `有無附傢俱` + `有無管理組織` +
    `村里`
) %>% append(formulas, .)

# model 6
formulas <- (
  `單價`~ 0 + `是否為店面` * `季數差` + 
    `到學校距離` + `到捷運站距離` + `到醫療機構距離` +
    I(`到學校距離`^2) + I(`到捷運站距離`^2) + I(`到醫療機構距離`^2) +
    `屋齡` + `房間數` +`衛浴數` + `總樓層數` + `租賃面積` + 
    `是否為一樓` + `土地使用分區` + `有無附傢俱` + `有無管理組織` +
    `村里`
) %>% append(formulas, .)

# model 7
formulas <- (
  `單價`~ 0 + `是否為店面` * `月數差` + 
    `到學校距離` + `到捷運站距離` + `到醫療機構距離` +
    I(`到學校距離`^2) + I(`到捷運站距離`^2) + I(`到醫療機構距離`^2) +
    `屋齡` + `房間數` +`衛浴數` + `總樓層數` + `租賃面積` + 
    `是否為一樓` + `土地使用分區` + `有無附傢俱` + `有無管理組織`
) %>% append(formulas, .)

# model 8
formulas <- (
  `單價`~ 0 + `是否為店面` * `季數差` + 
    `到學校距離` + `到捷運站距離` + `到醫療機構距離` +
    I(`到學校距離`^2) + I(`到捷運站距離`^2) + I(`到醫療機構距離`^2) +
    `屋齡` + `房間數` +`衛浴數` + `總樓層數` + `租賃面積` + 
    `是否為一樓` + `土地使用分區` + `有無附傢俱` + `有無管理組織`
) %>% append(formulas, .)

# Perform regression estimate and save results
for (ii in 1:length(formulas)) {
  lm(formulas[[ii]], data = lease_sf) %>% 
    write_result(., paste("model_", ii, "_results.csv", sep = ""))
}