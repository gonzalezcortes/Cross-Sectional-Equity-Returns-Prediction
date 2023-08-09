####################################################################
####################   Training with Real Data  ####################
####################################################################

# 1) This code loads a data set with the stock market data, and makes the some
# transformations in order to be use for training.

# 2) Then in the script the parameters are defined for creating training, 
# validation, and testing samples. It uses these samples to train different 
# models, specifically an Ordinary Least Squares (OLS) model (model 1)
# using a rolling window approach where the model is refit each year and 
# used for predictions over the next year. 

#3) The predictions are stored for later analysis, saving the Results in CSV 
# files, along with corresponding date and stock data. 

####################################################################

library(rstudioapi)
# Getting the path of your current open file
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path

source('src/preProcessing.R')
source('src/sampleSplitting.R')
source('src/trainingModels.R')
source('src/auxiliaries.R')


##### Open Data #####
n_dates <- 480 #Number of Months
n_char <- 904 #Number of characteristics (variables)
n_stocks <- 501 #Number of Stocks

## if data has not been transformed, call the get_data() to process the data.
#df_pivot <- get_data(n_dates, n_char, n_stocks) #function to get the data

## if data is already transformed, call the load_transformed_data() to open the saved file.
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

##refitting the entire model once per year
#real_values <- c()
#real_dates <- as.Date(character())
#real_stocks <- c()

#Model 1 - OLS
model_1_predictions <- c()
r2_scores <- c()

for (month_index in seq(training_first, training_stop, by = 12)){
    iterations = iterations + 1
    print(paste0("Iteration ",iterations))

    samples <- get_samples(df_pivot, returns, month_index, training_first, validation_step, testing_step)
    
    #real_values <- c(real_values, samples$testing$Y)
    #real_dates <- c(real_dates, as.Date(samples$testing$Date))
    #real_stocks <- c(real_stocks, samples$testing$Stock)
    
    mtrain <- mean(samples$training$Y) #mtrain is the mean of y train
    
    predictions <- ols_model(samples) #first model
    model_1_predictions <- c(model_1_predictions, predictions)

    r2_score <- r2(model_1_predictions, real_values, mtrain)
    r2_scores <- c(r2_scores, r2_score)
    print(r2_score)
    
    # Delete object to release memory
    rm(samples)
}


##### Save data ###
#df_real <- data.frame("Date" = unlist(real_dates), "Stock" = unlist(real_stocks), "Values" = unlist(real_values))
#write.csv(df_real, "../results/actual_testing_values.csv", row.names=TRUE)

df_m1 <- data.frame("Date" = unlist(real_dates), "Stock" = unlist(real_stocks), "Values" = unlist(model_1_predictions))
write.csv(df_m1, "../results/model_1_predictions.csv", row.names=TRUE)

#print(r2_scores)

#df_m2 <- data.frame("Date" = unlist(real_dates), "Stock" = unlist(real_stocks), "Values" = unlist(model_2_predictions))
#write.csv(df_m2, "../results/model_2_predictions.csv", row.names=TRUE)