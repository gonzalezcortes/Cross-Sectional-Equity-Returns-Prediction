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
  
  print(paste0(dates[training_start],' - ', dates[training_end],' - ', 
               dates[validation_start],' - ',dates[validation_end],' - ',
               dates[testing_start],' - ', dates[testing_end]))
  
  training_sample <- df %>% filter(Date >= dates[training_start]
                                   & Date <= dates[training_end])
  
  validation_sample <- df %>% filter(Date >= dates[validation_start]
                                   & Date <= dates[validation_end])
  
  testing_sample <- returns %>% filter(Date >= dates[testing_start]
                                   & Date <= dates[testing_end])
  
  return(list(training_sample, validation_sample, testing_sample))
  
}
