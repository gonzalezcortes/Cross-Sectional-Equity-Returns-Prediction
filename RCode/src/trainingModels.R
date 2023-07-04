set.seed(8)
library("ranger")

ols_model <- function(samples){
  training_data <- subset(samples$training, select = -Date)
  validation_data <- subset(samples$validation, select = -Date)
  
  testing_data <- subset(samples$testing, select = -Date)

  ols.model <- lm(Y ~ ., data = training_data)
  predictions <- array(predict(ols.model, newdata = testing_data))

  return(predictions)
}

ranger_model <- function(samples){
  training_data <- subset(samples$training, select = -Date)
  validation_data <- subset(samples$validation, select = -Date)
  
  testing_data <- subset(samples$testing, select = -Date)
  
  ranger_model <- ranger(Y ~ ., data = training_data)
  
  predictions <- array(predict(ranger_model, newdata = testing_data))
  
  return(predictions)
}

