set.seed(8)
library("ranger")
library(glmnet)
source('src/metrics.R')


ols_model <- function(samples){
    # No validation
    stocks <- unique(samples$training$Stock)
    
    training_data <- subset(samples$training)
    validation_data <- subset(samples$validation)
    testing_data <- subset(samples$testing)
    
    real_dates <- as.Date(character())
    actual_values <- c()
    
    stock_vector <- c()
    predictions_vector <- c()

    
    for (s in stocks){
        print(s)
        train <- training_data[training_data$Stock == s, ]
        #validation <- validation_data %>% filter(Stock == s) %>% as.data.frame()
        test <- testing_data[testing_data$Stock == s, ]
        
        #List of dates
        testing_dates <- as.Date(test$Date)
        
        #Training data
        #training_data_f <- subset(training_data_s, select = c(-Date,-Stock))
        #testing_data_f <- subset(testing_data_s, select = c(-Date,-Stock))
        
        train <- train[, !(colnames(train) %in% c("Date", "Stock"))]
        test <- test[, !(colnames(test) %in% c("Date", "Stock"))]
        
        ols.model <- lm(Y ~ ., data = train)
        predictions <- array(predict(ols.model, newdata = test))
        
        #save data
        real_dates <- c(real_dates, testing_dates)
        actual_values <- c(actual_values, test$Y)
        
        stock_vector <- c(stock_vector, rep(s, length(predictions)))
        predictions_vector <- c(predictions_vector, predictions)
    }
    
    output_data <- data.frame(
        
        Date = real_dates,
        Stock = stock_vector,
        Prediction = predictions_vector,
        Actual = actual_values
    )
    return(output_data)
}


lasso_ridge_model <- function(samples, LOR){
    # No validation
    stocks <- unique(samples$training$Stock)
    
    training_data <- subset(samples$training)
    validation_data <- subset(samples$validation)
    testing_data <- subset(samples$testing)
    
    real_dates <- as.Date(character())
    actual_values <- c()
    
    stock_vector <- c()
    predictions_vector <- c()
    
    
    for (s in stocks){
        #print(s)
        train <- training_data[training_data$Stock == s, ]
        validate <- validation_data[validation_data$Stock == s, ]
        test <- testing_data[testing_data$Stock == s, ]
        
        #List of dates
        testing_dates <- as.Date(test$Date)
        
        #Training data
        #training_data_f <- subset(training_data_s, select = c(-Date,-Stock))
        #testing_data_f <- subset(testing_data_s, select = c(-Date,-Stock))
        
        train <- train[, !(colnames(train) %in% c("Date", "Stock"))]
        test <- test[, !(colnames(test) %in% c("Date", "Stock"))]
        
        # Training and testing data
        x_train <- as.matrix(train[, !(colnames(train) %in% c("Date", "Stock", "Y"))])
        y_train <- train$Y
        
        x_validate <- as.matrix(validate[, !(colnames(validate) %in% c("Date", "Stock", "Y"))])
        y_validate <- validate$Y
        
        x_test <- as.matrix(test[, !(colnames(test) %in% c("Date", "Stock", "Y"))])
        
        
        
        ################# Validation #######################
        fit_all <- glmnet(x_train, y_train, alpha = LOR) # alpha 1 Lasso; alpha = 0 for Ridge
        
        #get sequences of lambdas, given by the glmnet package
        lambda_seq <- fit_all$lambda
        
        #internal function to calculate best lambda
        getBestLambda <- function(lambda) {
            predictions_validation <- predict(fit_all, s = lambda, newx = x_validate)
            r2_score = 1 - sum((y_validate - predictions_validation)^2) / sum((y_validate - mean(y_validate))^2)
            return(r2_score)
        }
        
        #Apply function over a lambda sequence
        r2_values <- sapply(lambda_seq, getBestLambda)
        
        # Find the lambda that gives the maximum R^2 value
        best_lambda <- lambda_seq[which.max(r2_values)]
        
        # Refit the model with the best lambda
        fit <- glmnet(x_train, y_train, alpha = LOR, lambda = best_lambda)
        
        #######################################################
        
        # Predict
        predictions <- predict(fit, s = best_lambda, newx = x_test) # s is the lambda value
        
        
        #save data
        real_dates <- c(real_dates, testing_dates)
        actual_values <- c(actual_values, test$Y)
        
        stock_vector <- c(stock_vector, rep(s, length(predictions)))
        predictions_vector <- c(predictions_vector, predictions)
    }
    
    output_data <- data.frame(
        
        Date = real_dates,
        Stock = stock_vector,
        Prediction = predictions_vector,
        Actual = actual_values
    )
    return(output_data)
}






ranger_model_old <- function(samples){
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

ols_model_old <- function(samples){
    # No validation
    
    training_data <- subset(samples$training, select = c(-Date,-Stock))
    validation_data <- subset(samples$validation, select = c(-Date,-Stock))
    testing_data <- subset(samples$testing, select = c(-Date,-Stock))
    
    ols.model <- lm(Y ~ ., data = training_data)
    
    predictions <- array(predict(ols.model, newdata = testing_data))
    
    return(predictions)
}


