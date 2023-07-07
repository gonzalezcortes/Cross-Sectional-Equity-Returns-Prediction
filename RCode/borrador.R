# Load necessary libraries
library(ranger)
#install.packages("devtools")
#install.packages("caret")
library(caret)


# Use mtcars dataset, predicting mpg based on all other variables
data(mtcars)

# Split data into training, validation, and test sets
set.seed(123)
trainIndex <- createDataPartition(mtcars$mpg, p = .6, list = FALSE, times = 1)
trainSet <- mtcars[ trainIndex,]
tempSet <- mtcars[-trainIndex,]

# Split the remaining data to validation and test sets
validIndex <- createDataPartition(tempSet$mpg, p = .5, list = FALSE, times = 1)
validSet <- tempSet[ validIndex,]
testSet <- tempSet[-validIndex,]

# Define the training control
train_control <- trainControl(method = "cv", number = 5)

# Define the search grid for the parameters
grid <- expand.grid(
  mtry = c(1,2,3),
  splitrule = "variance",
  min.node.size = 1, #Default
  max.depth = c(0, 1, 2, 3, 4, 5, 6),
  num.trees = 500
)

# Train random forest model with parameter tuning
rf_model <- caret::train(mpg ~ ., 
                         data = trainSet, 
                         method = "ranger", 
                         trControl = train_control, 
                         tuneGrid = grid)

# Print the best tuning parameters
print(rf_model$bestTune)

# Use model to predict on validation set
valid_pred <- predict(rf_model, newdata = validSet)

# Evaluate model performance on validation set
valid_results <- postResample(pred = valid_pred, obs = validSet$mpg)
print(valid_results)

# If the model performance is satisfactory, predict on test set
test_pred <- predict(rf_model, newdata = testSet)

# Evaluate model performance on test set
test_results <- postResample(pred = test_pred, obs = testSet$mpg)
print(test_results)
