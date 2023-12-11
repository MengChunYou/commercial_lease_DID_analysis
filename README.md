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
 │    └── robustness_check.R  
 │ 
 ├── outputs/                   
 │    ├── descriptive_statistics/                 
 │    │    ├── variable_summary_for_2_groups.txt
 │    │    ├── lease_records_map.png
 │    │    └── average_unit_prices_time_series.png
 │    ├── regression_results/
 │    │    ├── model_1_results.txt
 │    │    ├── model_2_results.txt
 │    │    └── ...
 │    └── robustness_check_results/
 │         ├── coefficient_ci.png
 │         ├── parameter_1_results.txt
 │         ├── parameter_2_results.txt
 │         └── ...
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
