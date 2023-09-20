#Analysis of the Returns using the returns predictions.
library(ggplot2)
library(rstudioapi)
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path
source('src/preProcessing.R')
source('src/sampleSplitting.R') # to filter the data
source('src/metrics.R') # To get metric, R2

## Load data ##


model_ols3 <- as.data.frame(read.csv(file = "../results/combined_predictions_1_OLS3.csv", header = TRUE))


#model_2 <- as.data.frame(read.csv(file = "../results/combined_predictions_2.csv", header = TRUE))
#model_3 <- as.data.frame(read.csv(file = "../results/combined_predictions_3.csv", header = TRUE))

model_2 <- as.data.frame(read.csv(file = "../results/combined_predictions_2_standard.csv", header = TRUE))
model_3 <- as.data.frame(read.csv(file = "../results/combined_predictions_3_standard.csv", header = TRUE))

### Global R2 ###
r2_metric(model_ols3$Prediction, model_ols3$Actual)
r2_metric(model_2$Prediction, model_2$Actual)
r2_metric(model_3$Prediction, model_3$Actual)


### R2OOSi ####
## Get the identifier of the stock
stocks <- unique(model_2$Stock)

# Get the R2 for each stock as De Nard (2022)
index <- 1
r2_results_1 <- c()
r2_results_2 <- c()
r2_results_3 <- c()

for (stock in stocks) {
    #filter the data according the stock
    model_1_filtered <- filter_by_stock(model_ols3, stock)
    model_2_filtered <- filter_by_stock(model_2, stock)
    model_3_filtered <- filter_by_stock(model_3, stock)
    
    #calculate the R2
    r2Stock_1 <- r2_metric(model_1_filtered$Prediction, model_1_filtered$Actual)
    r2Stock_2 <- r2_metric(model_2_filtered$Prediction, model_2_filtered$Actual)
    r2Stock_3 <- r2_metric(model_3_filtered$Prediction, model_3_filtered$Actual)
    
    #r2Stock_1 <- r2_Gu(model_1_filtered$Prediction, model_1_filtered$Actual, mean(model_1_filtered$Actual))
    #r2Stock_2 <- r2_Gu(model_2_filtered$Prediction, model_2_filtered$Actual, mean(model_1_filtered$Actual))
    #r2Stock_3 <- r2_Gu(model_3_filtered$Prediction, model_3_filtered$Actual, mean(model_1_filtered$Actual))
    
    r2_Gu
    ##print(r2Stock)
    
    #Add the results to a list
    r2_results_1 <- c(r2_results_1, r2Stock_1)
    r2_results_2 <- c(r2_results_2, r2Stock_2)
    r2_results_3 <- c(r2_results_3, r2Stock_3)
    index <- index + 1
    
}
mean(r2_results_1)
mean(r2_results_2)
mean(r2_results_3)

r2_results_1 <- r2_results_1 * 100
r2_results_2 <- r2_results_2 * 100
r2_results_3 <- r2_results_3 * 100

violin_results <- data.frame(
  Value = c(r2_results_1, r2_results_2, r2_results_3),
  Array = factor(rep(c("OLS-3", "Lasso", "Ridge"), each = length(r2_results_2)))
)


ggplot(violin_results, aes(x = Array, y = Value)) +
  geom_violin() +
  geom_boxplot(width = 0.1) +
  theme_minimal() +
  labs(title = "Large Covariate Vector",
       x = "Models",
       y = "R2")
 



################# evaluate as Gu #############
df_pivot <- load_transformed_data() #load data that was already saved
df_pivot$Date <- as.Date(as.character(df_pivot$Date), format = "%Y%m%d") #Convert to date format
dates <- unique(df_pivot$Date)

returns <- get_returns(dates, stocks) #From the exretMat.RData file
training_first <- 144
# A validation sample, retaining the next 20%. (96) -> (144+96)
validation_step <- 96
# Testing sample containing the next 12 months of data
testing_step <- 12
iterations <- 0
n_dates <- 480
training_stop <- n_dates-validation_step-testing_step

r2_results_1_b <- c()
r2_results_2_b <- c()
r2_results_3_b <- c()


for (stock in stocks) {
  return_filtered <- filter_by_stock(returns, stock)
  mtrain_list <- c()
  
  
  model_1_filtered <- filter_by_stock(model_ols3, stock)
  model_2_filtered <- filter_by_stock(model_2, stock)
  model_3_filtered <- filter_by_stock(model_3, stock)
  
  for (month_index in seq(training_first, training_stop, by = 12)){
    mtrain <- mean(return_filtered[1:month_index, ]$Returns)
    mtrain_list <- c(mtrain_list, mtrain)
  }
  

  r2Stock_1 <- r2_Gu(model_1_filtered$Prediction, model_1_filtered$Actual, mean(mtrain_list))
  r2Stock_2 <- r2_Gu(model_2_filtered$Prediction, model_2_filtered$Actual, mean(mtrain_list))
  r2Stock_3 <- r2_Gu(model_3_filtered$Prediction, model_3_filtered$Actual, mean(mtrain_list))
  
  r2_results_1_b <- c(r2_results_1_b, r2Stock_1)
  r2_results_2_b <- c(r2_results_2_b, r2Stock_2)
  r2_results_3_b <- c(r2_results_3_b, r2Stock_3)
  index <- index + 1

  #mtrain <- mean(return_filtered[1:month_index, ]$Returns)
  #print(mtrain)  
}

mean(r2_results_1_b)
mean(r2_results_2_b)
mean(r2_results_3_b)

r2_results_1_b <- r2_results_1_b * 100
r2_results_2_b <- r2_results_2_b * 100
r2_results_3_b <- r2_results_3_b * 100

violin_results_b <- data.frame(
  Value = c(r2_results_1_b, r2_results_2_b, r2_results_3_b),
  Array = factor(rep(c("OLS-3", "Lasso", "Ridge"), each = length(r2_results_2_b)))
)


ggplot(violin_results_b, aes(x = Array, y = Value)) +
  geom_violin() +
  geom_boxplot(width = 0.1) +
  theme_minimal() +
  labs(title = "Large Covariate Vector -- ROOS as GU et al.",
       x = "Models",
       y = "R2")




