library(ranger)

num.trees <- c(100, 200, 500)
mtry <- c(2, 3, 4)

best.model <- NULL
best.accuracy <- 0

set.seed(42)

random_df <- function(len){

  df <- data.frame(
    x1 = runif(len, 0, 100),
    x2 = runif(len, 0, 100),
    x3 = runif(len, 0, 100),
    x4 = runif(len, 0, 100),
    Y = factor(rbinom(len, 1, 0.5)) # binary target
  )
  return(df)
}

train_data <- random_df(500)
validation_data <- random_df(200)
testing_data <- random_df(100)

for (nt in num.trees) {
  for (mt in mtry) {
    # Train the model with the current hyperparameters
    model <- ranger(Y ~ ., data = train_data, num.trees = nt, mtry = mt)
    
    # Make predictions on the validation set
    predictions <- predict(model, data = validation_data)$predictions
    
    # Calculate accuracy
    accuracy <- sum(predictions == validation_data$target_variable) / nrow(validation_data)
    print(accuracy)    
    # If this model is better than our best model so far, update the best model and best accuracy
    if (accuracy > best.accuracy) {
      best.model <- model
      best.accuracy <- accuracy
    }
  }
}

# Print the best hyperparameters and best accuracy
print(best.model)
print(paste('Best Accuracy:', best.accuracy))

# Predict on the test set with the best model
predictions <- predict(best.model, data = test_data)$predictions

# Calculate accuracy on the test set
accuracy <- sum(predictions == test_data$target_variable) / nrow(test_data)

print(paste('Test Accuracy:', accuracy))

