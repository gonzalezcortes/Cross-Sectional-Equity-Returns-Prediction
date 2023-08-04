#####   R code  #####
##### June 2023 #####
#path <- getwd()
#setwd(path) #set path

print(getwd())

get_data <- function(n_dates, n_char, n_stocks){
  library(dplyr)
  library(tidyr) #library to pivot the dataframe
  ########## Load Data ##########
  load('../data/bigcharMat.RData')
  #load('../data/exretMat.RData')
  dates <- read.csv(file = "data/dates.csv", header = FALSE)
  dates <- as.vector(dates$V1) # Convert as vector
  stocks <- read.csv(file = "data/permno.csv", header = FALSE)
  stocks <- as.vector(stocks$V1) # Convert as vector
  
  #print(memuse::Sys.meminfo()) #Memory check
  ########## Convert Data ##########
  
  
  # Convert to new dimension 480 months, 904 characteristics, 501 companies.
  #data_0 <- array(fsmat, dim=c(n_dates, n_char, n_stocks))
  data_0 <- as.vector(fsmat)
  length(data_0)
  rm(fsmat) #delete unused variable to free memory
  #print(memuse::Sys.meminfo()) #Memory check
  
  # Convert to new dimensions 480 months, 501 companies.
  #returns <- array(mRetPerc, dim=c(n_dates, n_stocks))
  #returns <- as.vector(mRetPerc)
  #rm(mRetPerc) #delete unused variable to free memory
  #print(memuse::Sys.meminfo()) #Memory check
  
  #Create titles for the characteristics, the dataset that is design as a
  #3D matrix in the matlab code needs to be pass to 2D
  chars <- as.vector(paste0("x_", 0:(n_char-1)))
  dates_indices <- as.vector(rep(rep(dates, each = n_char), times = n_stocks))
  length(dates_indices)
  
  char_indices <- rep(chars, times = n_dates * n_stocks)
  length(char_indices)
  
  stocks_indices <- rep(stocks, each = n_dates * n_char)
  length(stocks_indices)
  length(unique(stocks_indices))
  
  ########## Combined Data ##########
  combined_df <- data.frame('Date' = dates_indices, 'Characteristic' = char_indices, 'Value' = data_0, 'Stock' = stocks_indices)
  rm(dates_indices, char_indices, data_0, stocks_indices)  #delete unused variable to free memory
  #print(head(combined_df, 1000))
  #print(memuse::Sys.meminfo()) #Memory check
  
  ### pivot the table ###
   df_pivot <- combined_df %>%
    pivot_wider(names_from = Characteristic, values_from = Value) %>%
    group_by(Stock, Date)
  
  rm(combined_df) #delete unused df
  #write.csv(df_pivot, "data/df_pivot.csv", row.names=TRUE) #Save data
  #save(df_pivot, file = "data/df_pivot.RData")
  return(df_pivot)

}


get_returns <- function(dates, stocks){
  #ret <- array(load('../data/exretMat.RData'), dim=c(n_dates, n_stocks))

  load('../data/exretMat.RData')
  returns <- as.vector(mRetPerc)
  
  date_list_rep <- rep(dates, times=length(stocks))
  stock_list_rep <- rep(stocks, each=length(dates))
  
  combined_returns <- data.frame('Date' = date_list_rep, 'Returns' = returns, 'Stock' = stock_list_rep)
  return(combined_returns)
  
}

load_generated_data <- function() {
  file_paths <- c('../SimulatedData/SimuData_p50/c1.csv', '../SimulatedData/SimuData_p50/r1_1.csv', '../SimulatedData/SimuData_p50/r2_1.csv', 
                  '../SimulatedData/SimuData_p100/c1.csv', '../SimulatedData/SimuData_p100/r1_1.csv', '../SimulatedData/SimuData_p100/r2_1.csv')
  data_list <- lapply(file_paths, read.csv)
  names(data_list) <- file_paths
  print(paste0(file_paths, " loaded"))
  return(data_list)
}

