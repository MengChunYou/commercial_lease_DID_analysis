# commercial_lease_DID_analysis

## Table of Contents
- [Repository Structure](#repository-structure)

## Repository Structure
```plaintext
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
 │         └── model_2_estimated_coef_plot.png
 │
 ├── reports/                    
 │    ├── report.pdf
 │    └── presentation.pdf
 │
 ├── main_script.R
 ├── README.md               
 ├── requirements.txt
 └── .gitignore   
```
