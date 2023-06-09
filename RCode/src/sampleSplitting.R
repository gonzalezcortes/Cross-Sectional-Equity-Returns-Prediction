library(dplyr)

get_samples <- function(df, returns, month_index, training_first, validation_step, testing_step){
  
  dates <- df$Date
  
  #training_start <- month_index-training_first
  training_start <- 1
  training_end <- month_index
  
  validation_start <- training_end + 1
  validation_end <- month_index+validation_step
  
  testing_start <- validation_end + 1
  testing_end <- month_index+validation_step+testing_step
  
  df$Y <- returns$Returns
  
  training_sample <- df %>% filter(Date >= dates[training_start]
                                   & Date <= dates[training_end]) %>% as.data.frame()
  
  validation_sample <- df %>% filter(Date >= dates[validation_start]
                                   & Date <= dates[validation_end]) %>% as.data.frame()
  
  testing_sample <- df %>% filter(Date >= dates[testing_start]
                                   & Date <= dates[testing_end]) %>% as.data.frame()
  
  
  return(list("training" = training_sample, "validation" = validation_sample, 
              "testing" = testing_sample))
}
