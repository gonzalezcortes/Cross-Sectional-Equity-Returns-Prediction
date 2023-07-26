### This file contains the training of models using generated data ###

library(rstudioapi)
# Getting the path of your current open file
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path

## Call libraries
source('src/preProcessing.R')
source('src/sampleSplitting.R')
source('src/trainingModels.R')
source('src/auxiliares.R')

### With preprocessing get synthetic returns
# 1 -> SimuData_p50/c1.csv, 
# 2 -> SimuData_p50/r1_1.csv, 
# 3 -> SimuData_p50/r2_1.csv,
# 4 -> SimuData_p100/c1.csv,
# 5 -> SimuData_p100/r1_1.csv, 
# 6 -> SimuData_p100/r2_1.csv

data_list <- load_generated_data()


