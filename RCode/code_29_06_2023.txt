#####   R code  #####
##### June 2023 #####
library(dplyr)
library(tidyr) #library to pivot the dataframe
#getwd()

path <- 'G:/My Drive/Research Papers/Cross Sectional Equity Returns 2023'
setwd(path)

########## Load Data ##########
load('data/bigcharMat.RData')
load('data/exretMat.RData')
dates <- read.csv(file = "data/dates.csv", header = FALSE)
dates <- as.vector(dates$V1) # Convert as vector
stocks <- read.csv(file = "data/permno.csv", header = FALSE)
stocks <- as.vector(stocks$V1) # Convert as vector

print(memuse::Sys.meminfo()) #Memory check
########## Convert Data ##########
n_dates <- 480 #Number of Months
n_char <- 904 #Number of characteristics (variables)
n_stocks <- 501 #Number of Stocks

# Convert to new dimension 480 months, 904 characteristics, 501 companies.
#data_0 <- array(fsmat, dim=c(n_dates, n_char, n_stocks))
data_0 <- as.vector(fsmat)
length(data_0)
rm(fsmat) #delete unused variable to free memory
print(memuse::Sys.meminfo()) #Memory check

# Convert to new dimensions 480 months, 501 companies.
#returns <- array(mRetPerc, dim=c(n_dates, n_stocks))
returns <- as.vector(mRetPerc)
rm(mRetPerc) #delete unused variable to free memory
print(memuse::Sys.meminfo()) #Memory check

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
print(head(combined_df, 1000))
print(memuse::Sys.meminfo()) #Memory check

### pivot the table ###

df_pivot <- combined_df %>%
  pivot_wider(names_from = Characteristic, values_from = Value) %>%
  group_by(Stock, Date)

write.csv(df_pivot, "data/df_pivot.csv", row.names=TRUE)

########## Combined Data ##########
print(memuse::Sys.meminfo()) #Memory check
print("end")
