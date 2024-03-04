# commercial_lease_DID_analysis

This repository contains the final project for the [Applied Econometrics](https://sites.google.com/view/cpelab/teaching/2023-applied-econometrics-%E6%87%89%E7%94%A8%E8%A8%88%E9%87%8F%E7%B6%93%E6%BF%9F%E5%AD%B8) course instructed by [Tzu-Ting Yang](https://sites.google.com/view/cpelab/), which took place from September to December 2023. The project focuses on quantifying the causal effect of crowd management on commercial lease prices.

## Table of Contents

- [Project Abstract](#project-abstract)
- [Repository Structure](#repository-structure)
- [Required Packages](#required-packages)

## Project Abstract

This project investigates the impact of crowd management on commercial lease price, using Taipei City's Level 3 epidemic alert from May to July 2021 as the empirical study period.During the COVID-19 pandemic, some countries or cities implemented crowd management to prevent the spread of the virus, resulting in corresponding economic losses. Rental costs for storefronts represent a fixed cost for physical businesses, accounting for approximately 15% of the total costs. Under crowd management policies, with reduced traffic, fluctuations in rental costs become crucial for the survival of physical businesses. Methodologically, this study utilizes Taipei City's real estate lease data and applies the difference-in-differences model, incorporating housing characteristics and proximity to building facilities to estimate the effects. Results indicate that during the control period, compared to the pre-control period, rental prices per square meter for storefronts decreased by approximately NT\$34.8. However, in the 2nd to 4th quarters after the control measures, prices increased by approximately NT\$58.3, NT\$39.8, and NT\$36.6, respectively.

## Repository Structure

``` plaintext
root/
 ├── data/                       
 │    ├── raw/
 │    │    ├── taiwan_village_polygons/
 │    │    ├── lease_records/
 │    │    └── facilities/
 │    └── processed/
 │         ├── study_area_polygons.RData
 │         └── processed_lease_records.RData
 │
 ├── src/ 
 │    ├── common_functions.R 
 │    ├── data_processing.R
 │    ├── descriptive_statistics.R
 │    ├── regression_estimate.R
 │    └── estimated_coefficients_plot.R
 │ 
 ├── outputs/                   
 │    ├── descriptive_statistics/                 
 │    │    ├── variable_summary_for_2_groups.txt
 │    │    ├── lease_records_map.png
 │    │    └── average_unit_prices_time_series/
 │    ├── regression_results/
 │    │    ├── model_1_results.csv
 │    │    ├── model_2_results.csv
 │    │    └── ...
 │    └── estimated_coefficients_plot/
 │         ├── model_1_estimated_coef_plot.png
 │         ├── model_2_estimated_coef_plot.png
 │         └── ...
 │
 ├── reports/                    
 │    ├── report.pdf
 │    └── slides.pdf
 │
 ├── main_script.R
 ├── README.md
 └── .gitignore   
```

- `reports/`: This directory contains presentation slides and report written in Traditional Chinese.

## Required Packages

- sf
- dplyr
- readxl
- zoo
- tmap
- ggplot2
- magrittr

Download the required packages by running the following command in R:

``` plaintext
install.packages(c("sf", "dplyr", "readxl", "magrittr", "zoo", "tmap", "ggplot2"))
```
