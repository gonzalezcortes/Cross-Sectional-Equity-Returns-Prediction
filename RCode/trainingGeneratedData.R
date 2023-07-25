### This file contains the training of models using generated data ###

library(rstudioapi)
# Getting the path of your current open file
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path

source('src/preProcessing.R')
source('src/sampleSplitting.R')
source('src/trainingModels.R')
source('src/auxiliares.R')