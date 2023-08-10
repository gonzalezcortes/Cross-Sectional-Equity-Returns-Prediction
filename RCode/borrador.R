library(glmnet)

# Set seed for reproducibility
set.seed(42)

# Number of observations
n <- 100

# Create three features with random values
X1 <- rnorm(n, mean = 5, sd = 2)
X2 <- rnorm(n, mean = 10, sd = 5)
X3 <- rnorm(n, mean = 0, sd = 1)

# Create a response variable based on the features with some added noise
y <- 3 + 2 * X1 - X2 + 0.5 * X3 + rnorm(n, mean = 0, sd = 3)

# Combine into a data frame
data <- data.frame(
    y = y,
    X1 = X1,
    X2 = X2,
    X3 = X3
)

# Print the first few rows to check
head(data)



# Extract the response variable (assuming it's named 'y')
y <- data$y

# Extract the feature variables
X <- as.matrix(data[,-which(names(data) == 'y')])

# Split the data into training and test sets based on time
train_size <- floor(0.7 * nrow(data))
X_train <- X[1:train_size,]
y_train <- y[1:train_size]
X_test <- X[(train_size + 1):nrow(data),]
y_test <- y[(train_size + 1):nrow(data)]

lasso_model <- glmnet(X_train, y_train, alpha = 1)

# You can either set a specific value or use the one that gives minimum mean squared error for the training data
best_lambda <- lasso_model$lambda.min
best_lambda

predictions <- predict(lasso_model, s = 0, newx = X_test)

mse <- mean((y_test - predictions)^2)
print(paste("Mean Squared Error:", mse))





