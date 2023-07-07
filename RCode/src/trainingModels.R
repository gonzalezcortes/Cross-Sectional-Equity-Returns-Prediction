set.seed(8)
library("ranger")

ols_model <- function(samples){
  # No validation
  training_data <- subset(samples$training, select = c(-Date,-Stock))
  validation_data <- subset(samples$validation, select = c(-Date,-Stock))
  
  testing_data <- subset(samples$testing, select = c(-Date,-Stock))

  #ols.model <- lm(Y ~ ., data = training_data)
  ols.model <- lm(Y ~ ., data = training_data)
  predictions <- array(predict(ols.model, newdata = testing_data))

  return(predictions)
}

ranger_model <- function(samples){
  #Drop Data and Stock columns
  training_data <- subset(samples$training, select = c(-Date,-Stock))
  validation_data <- subset(samples$validation, select = c(-Date,-Stock))
  testing_data <- subset(samples$testing, select = c(-Date,-Stock))
  
  ranger_model <- ranger(Y ~ ., data = training_data)
  
  predictions <- array(predict(ranger_model, newdata = testing_data))
  
  return(predictions)
}

