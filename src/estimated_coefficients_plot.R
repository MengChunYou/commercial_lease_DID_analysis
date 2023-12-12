# estimated_coefficients_plot.R

library(magrittr)
library(ggplot2)

# set font family
windowsFonts(JhengHei = windowsFont(family = "Microsoft JhengHei"))

save_estimated_coef_plot <- function(input_name) {
  
  # This is a function to read result of estimated coefficients and make plot.
  
  output_name <- gsub("results.csv", "estimated_coef_plot.png", input_name)
  result_df <- paste("outputs/regression_results/", input_name, sep = "") %>% 
    read.csv()
  
  t_name <- result_df[grep("^是否為店面TRUE:", result_df$coef), 1][1] %>% 
    gsub("^是否為店面TRUE:", "", .) %>% 
    gsub("[[:digit:][:punct:]]", "", .)
  
  # Open a PNG device for graphics output
  paste("outputs/estimated_coefficients_plot/", output_name, sep = "") %>% 
    open_png()
  
  # Create Plot
  p <- result_df[grep("^是否為店面TRUE:", result_df$coef), ] %>% 
    mutate(coef = gsub("^是否為店面TRUE:", "", coef)) %>% 
    mutate(coef = as.numeric(gsub(t_name, "", coef))) %>% 
    rename(t = coef) %>% 
    ggplot() +
    geom_ribbon(aes(x = t, ymin = lower, ymax = upper), fill = "grey70", alpha = 0.5) +
    geom_line(aes(x = t, y = estimate), color = "blue", size = 1) +
    geom_vline(xintercept = 0, col = "darkgray", lty = 2, size = 1) +
    labs(title = "三級警戒措施對店面類型不動產租賃單價的影響", 
         x = paste("與三級警戒公告的", t_name, sep = ""), y = "Estimated coefficients") +
    theme_bw() +
    theme(text = element_text(family = "JhengHei", size = 20),
          plot.title = element_text(hjust = 0.5, face = "bold"),
          legend.position = "bottom")
  
  print(p)
  
  # Close the PNG device
  dev.off()
}



# run save_estimated_coef_plot function
input_names <- list.files("outputs/regression_results/", pattern='results.csv')
for (input_name in input_names) {
  save_estimated_coef_plot(input_name)
}