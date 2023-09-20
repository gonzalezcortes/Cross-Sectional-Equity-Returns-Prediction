####################################################################
#####################   Portfolio evaluation  ######################
####################################################################

# 1) The code opens the necessary libraries and it also call some functions,
# called 'metrics' and 'auxiliaries' located at the src folder.

# 2) Then the script reads the CSV files of actual stock return values and the 
# predicted values from different models. These files were created in the
# 'trainingRealData.R' file.

# 3) Then there is a performance evaluation, where the code evaluates the 
# monthly out-of-sample prediction performance at the stock level for one 
# of the models using the function monthly_stock_level_prediction_performance().

# 4) Then there is the portfolio construction and evaluation where the script 
# constructs an equally weighted portfolio using the actual returns and 
# the zero net portfolios using the predicted returns from the models. 


# 5) The scripts generates plots to visualize the performance of the created
# portfolios, comparing the equally weighted portfolio with each of the zero 
# net portfolios.


# 6) Finally the code calculates the R squared value for one model's predictions 
# against the actual values, serving as a measure of the model's predictive 
# accuracy.

####################################################################
library(ggplot2)
library(reshape2)
library(dplyr)
library(rstudioapi)
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path

source('src/metrics.R')
source('src/auxiliaries.R')
years <- as.character(seq(1997, 2016))

### Open results ###
actual_values <- read.csv(file = "../results/actual_testing_values.csv", header = TRUE)
actual_values$Date <- as.Date(actual_values$Date)

actual_values

#m1 <- read.csv(file = "../results/model_x.csv", header = TRUE)
#m1 <- read.csv(file = "../results/model_x_predictions.csv", header = TRUE)
#m1$Date <- as.Date(m1$Date)
#m1$Date <- actual_values$Date
m1 <- read.csv(file = "../results/combined_predictions_1_OLS3.csv", header = TRUE)
m1$Date <- as.Date(m1$Date)

m2 <- read.csv(file = "../results/combined_predictions_2_standard.csv", header = TRUE)
m2$Date <- as.Date(m2$Date)

m3 <- read.csv(file = "../results/combined_predictions_3_standard.csv", header = TRUE)
m3$Date <- as.Date(m3$Date)

print("Monthly out-of-sample stock-level prediction performance")
### Monthly out-of-sample stock-level prediction performance ###
monthly_stock_level_prediction_performance(m1)

monthly_stock_level_prediction_performance(m2)

monthly_stock_level_prediction_performance(m3)

##r2(m1$Values,actual_values$Values)
##rsq(m1$Values,actual_values$Values)

############ Portfolio ############

# The 'equally_weighted_portfolio()' function calculates the average return for 
# each unique month with an equally weighted investment across all stocks 
# for that month. To finally returns the cumulative log return of these mean 
# monthly returns. 


# The 'zero_net_portfolio()' function constructs a zero-investment portfolio 
# based on the deciles of the predicted stock returns. 
# For each unique month, it identifies the top 10% of stocks to buy (decile 10) 
# and the bottom 10% of stocks to sell (decile 1).
# Then calculates the mean return of the stocks in the 'buy' portfolio, 
# and accumulates these monthly returns. 
# The function finally returns the cumulative log return of these mean monthly 
# returns.
### Equally weighted ###
portfolio_equally_weighted <- calculate_equally_weighted_portfolio(actual_values)
cumulative_equally_weighted <- calculate_cumulative_log_returns(portfolio_equally_weighted$Portfolio_Value)
plot_portfolio(cumulative_equally_weighted)


### Zero net ###
ze_1 <- zero_net_portfolio_a(m1)
ze_2 <- zero_net_portfolio_a(m2)
ze_3 <- zero_net_portfolio_a(m3)



########## PLOT ##################
Time = portfolio_equally_weighted$Date
df_results <- data.frame(Time, ze_1, ze_2, ze_3, cumulative_equally_weighted)
colnames(df_results) <- c("Time", "OLS-3", "Lasso", "Ridge", "Equally Weighted")

df_melted <- melt(df_results, id.vars = "Time")

ggplot(df_melted, aes(x = Time, y = value, color = variable)) +
  geom_line() +
  ggtitle("Portfolio Long only") +
  xlab("Time") +
  ylab("Cumulative Log Returns")


####### Long - Short #############

ze_4 <- long_short_portfolio(m1)
ze_5 <- long_short_portfolio(m2)
ze_6 <- long_short_portfolio(m3)

########## PLOT ##################

df_results_B <- data.frame(Time, ze_4, ze_5, ze_6, cumulative_equally_weighted)
colnames(df_results_B) <- c("Time", "OLS-3", "Lasso", "Ridge", "Equally Weighted")

df_melted_B <- melt(df_results_B, id.vars = "Time")

ggplot(df_melted_B, aes(x = Time, y = value, color = variable)) +
  geom_line() +
  ggtitle("Portfolio Long-short") +
  xlab("Time") +
  ylab("Cumulative Log Returns")
