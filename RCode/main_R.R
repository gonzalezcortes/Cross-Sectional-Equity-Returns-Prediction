#####   R code  #####
##### June 2023 #####
path <- getwd()
print(path)
setwd(path) #set path

source('src/preProcessing.R')
source('src/sampleSplitting.R')

##### Open Data #####
n_dates <- 480 #Number of Months
n_char <- 904 #Number of characteristics (variables)
n_stocks <- 501 #Number of Stocks

#df_pivot <- get_data(n_dates, n_char, n_stocks) #function to get the data
df_pivot <- load_transformed_data() #load data that was already saved
df_pivot$Date <- as.Date(as.character(df_pivot$Date), format = "%Y%m%d") #Convert to date format
dates <- unique(df_pivot$Date)
stocks <- unique(df_pivot$Stock)
returns <- get_returns(dates, stocks)

##### Training #####
# Sample splitting
# The procedure cyclically grows the training sample, refits the model annually,and uses it for predictions over the next year.
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
  samples <- get_samples(df_pivot, returns, month_index, training_first, validation_step, testing_step)
  
  training_sample <- samples[[1]]
  validation_sample <- samples[[2]]
  testing_sample <- samples[[3]]
  
  ####El validation test period está malo
  print("------------------")
  print("------------------")
}

