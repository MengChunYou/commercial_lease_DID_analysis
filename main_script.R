# main_script.R

# Set working directory to source file location
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

source("src/common_functions.R")

# 1: data processing
source("src/data_processing.R")

# 2: descriptive statistics
source("src/descriptive_statistics.R")

# 3: regression
source("src/regression_estimate.R")

# 4: plot estimated coefficients
source("src/estimated_coefficients_plot.R")

# end of main_script.R