# Load required package
library(MASS)

# Generate t-distributed data with df=5, mean=0, and scale=0.05^2
x_t <- rt(10000, df=5) * sqrt(0.05^2)

# Generate multivariate normal data with mean=0, covariance=0.05^2 * I_3
mu_vector <- c(0, 0, 0)
cov_matrix <- matrix(0.05^2, nrow=3, ncol=3)
diag(cov_matrix) <- 0.05^2
x_norm <- MASS::mvrnorm(10000, mu=mu_vector, Sigma=cov_matrix)[, 1]

# Set up the plotting layout
par(mfrow=c(1, 2))

# Plotting t-distribution
hist(x_t, col=rgb(0,1,0,0.5), main="t-distribution", xlab="Value", breaks=50)

# Plotting Normal distribution
hist(x_norm, col=rgb(1,0,0,0.5), main="Normal distribution", xlab="Value", breaks=50)

# Reset the plotting layout
par(mfrow=c(1, 1))
