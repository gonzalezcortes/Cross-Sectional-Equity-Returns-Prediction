set.seed(8)
library("ranger")
source('src/metrics.R')

ols_model <- function(samples){
  # No validation
  training_data <- subset(samples$training, select = c(-Date,-Stock))
  validation_data <- subset(samples$validation, select = c(-Date,-Stock))
  
  testing_data <- subset(samples$testing, select = c(-Date,-Stock))
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


RandomForest_model <- function(samples){
  training_data <- subset(samples$training, select = c(-Date,-Stock))
  validation_data <- subset(samples$validation, select = c(-Date,-Stock))
  testing_data <- subset(samples$testing, select = c(-Date,-Stock))
  
  best_model <- NULL
  best_performance <- 0
  mtry <- c(3, 5, 10, 20 ,30 ,50)
  n_trees = 500
  max_depth <- c(0, 1, 2, 3, 4, 5, 6)
  
  for (mxd in max_depth) {
    for (mt in mtry) {
      
      model <- ranger(Y ~ ., data = training_data, num.trees = n_trees, mtry = mt, max.depth = mxd)
      pred <- predict(model, data = validation_data)$predictions
      pred <- as.numeric(pred)
      real_values <- as.numeric(validation_data$Y)
      #print(predictions)
      performance <- rsq(pred, real_values) #r2
      print(performance)
      
      #final_predictions <- array(predict(model, newdata = testing_data))
      #print(final_predictions)
      
      if (performance > best_performance) {
        best_model <- model
        best_performance <- performance
      }
    }
  }
  final_predictions <- predict(best_model, data = testing_data)$predictions
  return(as.numeric(final_predictions))
}

