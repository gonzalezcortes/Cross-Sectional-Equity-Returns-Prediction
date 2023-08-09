library(dplyr)

get_samples_old <- function(df, returns, month_index, training_first, validation_step, testing_step){
  
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

#optimized
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
    
    training_dates <- dates[training_start:training_end]
    validation_dates <- dates[validation_start:validation_end]
    testing_dates <- dates[testing_start:testing_end]
    
    
    training_sample <- df %>% inner_join(data.frame(Date = training_dates), by = "Date")
    validation_sample <- df %>% inner_join(data.frame(Date = validation_dates), by = "Date")
    testing_sample <- df %>% inner_join(data.frame(Date = testing_dates), by = "Date")
    
    return(list("training" = training_sample, "validation" = validation_sample, 
                "testing" = testing_sample))
}
