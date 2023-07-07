#####         R code        #####
##### Portfolio - July 2023 #####

library(dplyr)
library(rstudioapi)
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path

source('src/metrics.R')
source('src/plot_functions.R')
years <- as.character(seq(1997, 2016))

### Open results ###
actual_values <- read.csv(file = "../results/actual_x.csv", header = TRUE)
actual_values$Date <- as.Date(actual_values$Date)

#m1 <- read.csv(file = "../results/model_x.csv", header = TRUE)
m1 <- read.csv(file = "../results/model_1_predictions.csv", header = TRUE)
m1$Date <- as.Date(m1$Date)
#m1$Date <- actual_values$Date

m2 <- read.csv(file = "../results/model_2_predictions_sin_validation_2.csv", header = TRUE)
m2$Date <- m2$Date


### Monthly out-of-sample stock-level prediction performance ###

monthly_stock_level_prediction_performance(predicted_df=m1, actual_df=actual_values)

##r2(m1$Values,actual_values$Values)
##rsq(m1$Values,actual_values$Values)

### Portfolio ###
eq <- equally_weighted_portfolio(returns = actual_values)

ze_1 <- zero_net_portfolio(actual_returns = actual_values, predicted_returns = m1)
#ze_2 <- zero_net_portfolio(actual_returns = actual_values, predicted_returns = m2)


##plot_portfolio(eq)
#plot_two_portfolios(ze)


plot_two_portfolios(c("Eq W", "M1"),eq, ze_1)
#plot_two_portfolios(c("Eq W", "M2"),eq, ze_2)

r2(m1$Values, actual_values$Values)


