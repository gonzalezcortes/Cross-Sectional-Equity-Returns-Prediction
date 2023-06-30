#####   R code  #####
##### June 2023 #####
path <- 'G:/My Drive/Research Papers/Cross Sectional Equity Returns 2023'
setwd(path)
source('RCode/src/preProcessing.R')
source('RCode/src/sampleSplitting.R')

##### Open Data #####
n_dates <- 480 #Number of Months
n_char <- 904 #Number of characteristics (variables)
n_stocks <- 501 #Number of Stocks

#df_pivot <- get_data(n_dates, n_char, n_stocks) #function to get the data
df_pivot <- load_transformed_data() #load data that was already saved
dates <- as.vector(unique(df_pivot$Date))
stocks <- as.vector(unique(df_pivot$Stock))

##### Training #####
# Sample splitting
# The procedure cyclically grows the training sample, refits the model annually,
# and uses it for predictions over the next year.
# The (first) training sample, comprising of the first 30% observations. (144 months)
training_first <- 144
# A validation sample, retaining the next 20%. (96) -> (144+96)
validation_step <- 96
# Testing sample containing the next 12 months of data
testing_step <- 12
iterations <- 0

#training_sample, validation_sample, testing_sample
training_stop <- n_dates-validation_step-testing_step
#refitting the entire model once per year
for (month_index in seq(training_first, training_stop, by = 12)){
  iterations = iterations + 1
  # training will finish in month_index
  training_start <- month_index-training_first
  validation_end <- month_index+validation_step
  testing_stop <- month_index+validation_step+testing_step
  print(paste0(iterations, " - ",training_start, " - " , month_index, " - ",
               validation_end," - ",testing_stop))
  
}

