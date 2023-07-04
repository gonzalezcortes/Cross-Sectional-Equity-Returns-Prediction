#####         R code        #####
##### Portfolio - July 2023 #####

library(dplyr)
library(rstudioapi)
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path

source('src/metrics.R')
years <- as.character(seq(1997, 2016))

### Open results ###
actual_values <- read.csv(file = "../results/actual_x.csv", header = TRUE)
actual_values$Date <- as.Date(actual_values$Date)

m1 <- read.csv(file = "../results/model_x.csv", header = TRUE)
m1$Date <-as.Date(m1$Date)


### r2 per Year ###
#r2PerYear(m1, actual_values, years)

### Portfolio ###
eq <- equally_weighted_portfolio(returns = actual_values, plot = TRUE)


plot_portfolio(eq)

