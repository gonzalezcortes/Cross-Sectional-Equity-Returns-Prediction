#####   R code  #####
##### June 2023 #####
path <- 'G:/My Drive/Research Papers/Cross Sectional Equity Returns 2023'
setwd(path)

source('RCode/src/preProcessing.R')

n_dates <- 480 #Number of Months
n_char <- 904 #Number of characteristics (variables)
n_stocks <- 501 #Number of Stocks

#df_pivot <- get_data(n_dates, n_char, n_stocks) #function to get the data

df_pivot <- load_transformed_data() #load data that was already saved
dates <- as.vector(unique(df_pivot$Date))
stocks <- as.vector(unique(df_pivot$Stock))
