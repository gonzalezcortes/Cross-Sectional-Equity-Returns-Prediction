### This file contains the training of models using generated data ###

library(rstudioapi)
# Getting the path of your current open file
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path
path <- getwd()

## Call libraries
source('src/preProcessing.R')
source('src/sampleSplitting.R')
source('src/trainingModels.R')
source('src/auxiliares.R')

### With preprocessing get synthetic returns
data_list <- load_generated_data()

p50_c1 <- data.frame(data_list[1]) #SimuData_p50/c1.csv
p50_r1_1 <- data.frame(data_list[2]) #SimuData_p50/r1_1.csv
p50_r2_1 <- data.frame(data_list[3]) #SimuData_p50/r2_1.csv

p100_c1 <- data.frame(data_list[4]) #SimuData_p100/c1.csv
p100_r1_1 <- data.frame(data_list[5]) #SimuData_p100/r1_1.csv
p100_r2_1 <- data.frame(data_list[6]) #SimuData_p100/r2_1.csv

print(dim(p50_c1))
print(dim(p50_r1_1))


############################
############################
############################




#library(glmnet)
hh <- 1

M <- 1
nump <- 50
mu <- 0.2 * sqrt(hh)
tol <- 1e-10

datanum <- 50

# Start to MCMC

#c <- paste0("p50_c", as.character(M))
#r1 <- paste0("p50_r", as.character(mo), "_", as.character(M))

for (mo in c(1, 2)) {
  
  title <- paste(dirname(path), "/SimulatedData/SimuData_p", as.character(datanum), "/Reg", as.character(hh), sep="")
  
  print(paste('### MCMC :', M, ', Model :', mo, ' ###'))
  N <- 200 # Number of CS tickers
  m <- nump * 2 # Number of Characteristics
  T <- 180 # Number of Time Periods
  
  per <- rep(1:N, T)
  time <- rep(1:T, each = N)
  stdv <- 0.05
  theta_w <- 0.005
  
  # Read Files
  ##path1 <- paste(dirstock, 'c', M, sep = '')
  ##path2 <- paste(dirstock, 'r', mo, '_', M, sep = '')
  c <- p50_c1
  r1 <- p50_r1_1
  
  # Prepare the Data
  # Add Some Elements
  
  daylen <- rep(N, T / 3)
  daylen_test <- daylen
  ind <- 1:floor(N * T / 3)
  
  
  xtrain <- c[ind, ]
  ytrain <- r1[ind, ]
  trainper <- per[ind]
  
  ind <- (floor(N * T / 3) + 1):(floor(N * (T * 2 / 3 - hh + 1)))
  
  xtest <- c[ind, ]
  ytest <- r1[ind, ]
  testper <- per[ind]
  
  l1 <- nrow(c)
  l2 <- length(r1)
  l3 <- l2 - sum(is.na(r1))
  
  ind <- (floor(N * T * 2 / 3) + 1):min(c(l1, l2, l3))
  xoos <- c[ind, ]
  yoos <- r1[ind, ]
  rm(c, r1)
  
  # Monthly Demean
  ytrain_demean <- ytrain - mean(ytrain)
  ytest_demean <- ytest - mean(ytest)
  mtrain <- mean(ytrain)
  mtest <- mean(ytest)
  
  # Calculate Sufficient Stats
  sd <- rep(0, ncol(xtrain))
  for (i in 1:ncol(xtrain)) {
    s <- sd(xtrain[, i])
    if (s > 0) {
      xtrain[, i] <- xtrain[, i] / s
      xtest[, i] <- xtest[, i] / s
      xoos[, i] <- xoos[, i] / s
      sd[i] <- s
    }
  }

  
  xtrain <- as.matrix(xtrain)
  xtest <- as.matrix(xtest)
  
  XX <- t(xtrain) %*% xtrain
  svd_res <- svd(XX)
  L <- svd_res$d[1]
  
  Y <- ytrain_demean
  XY <- t(xtrain) %*% Y
  
  # Start to Train
  
  # OLS
  r2_oos <- rep(0, 13)
  r2_is <- rep(0, 13)
  
  modeln <- 1
  groups <- 0
  nc <- 0
  
  
  xtrain <- as.data.frame(xtrain)
  xtest <- as.data.frame(xtest)
  
  # Fit the model without intercept
  clf <- lm(ytrain_demean ~ . -1, data = xtrain)
  
  # Predict and compute R-squared out-of-sample
  yhatbig1 <- predict(clf, newdata = xoos) + mtrain
  r2_oos <- list(modeln = 1 - sum((yhatbig1 - yoos)^2) / sum((yoos - mtrain)^2))
  
  # Predict and compute R-squared in-sample
  yhatbig1 <- predict(clf, newdata = xtrain) + mtrain
  r2_is <- list(modeln = 1 - sum((yhatbig1 - ytrain)^2) / sum((ytrain - mtrain)^2))
  
  # Get the model coefficients
  b <- coef(clf)
  
  # Construct the file path and save coefficients
  pathb <- paste(title, 'B', 'b', sep = "/")
  pathb <- paste(pathb, mo, M, modeln, sep = "_")
  pathb <- paste(pathb, ".csv", sep = "")

  # Save to csv
  write.csv(b, file = pathb, row.names = FALSE)
  
  # Display R-squared out-of-sample
  cat(paste("Simple OLS R2 : ", round(r2_oos$modeln, 3), "\n"))
  
  ##############################################################
  ##############################################################
  ##############################################################
  
  # Increase the model number
  modeln <- modeln + 1
  
  lossh <- function(y, yhat, mu) {
    r <- abs(yhat - y)
    l <- rep(0, length(r))
    ind <- r > mu
    l[ind] <- 2 * mu * r[ind] - mu^2
    ind <- r <= mu
    l[ind] <- r[ind]^2
    return(mean(l))
  }
  
  
  
  f_gradh <- function(w, X, y, mu) {
    X <- as.matrix(sapply(X, as.numeric))
    r <- X %*% w - y
    ind0 <- which(abs(r) <= mu)
    ind1 <- which(r > mu)
    indf1 <- which(r < -mu)
    grad <- t(X[ind0, ]) %*% (X[ind0, ] %*% w - y[ind0]) + mu * t(X[ind1, ]) %*% rep(1, length(ind1)) - mu * t(X[indf1, ]) %*% rep(1, length(indf1))
    return(grad)
  }
  
  
  
  
  
  # Define the soft thresholding function
  soft_threshold <- function(groups, nc, w, mu) {
    return(sign(w) * pmax(abs(w) - mu, 0))
  }
  
  # Define the proximal operator
  proximalH <- function(groups, nc, xtest, mtrain, ytest, w, X, y, mu, tol, L, l2, func) {
    dim <- nrow(X)
    max_iter <- 3000
    gamma <- 1 / L
    l1 <- l2
    v <- w
    
    xtest <- as.matrix(xtest)
    
    yhatbig1 <- xtest %*% w + mtrain
    r20 <- lossh(yhatbig1, ytest, mu) # Assume lossh is defined
    for(t in 1:max_iter) {
      vold <- v
      w_prev <- w
      w <- v - gamma * f_gradh(v, X, y, mu) # Assume f_gradh is defined
      mu1 <- l1 * gamma
      w <- func(groups, nc, w, mu1)
      v <- w + t / (t + 3) * (w - w_prev)
      if(sum((v - vold)^2) < sum(vold^2) * tol || sum(abs(v - vold)) == 0) {
        break
      }
    }
    return(v)
  }
  
  # Run the optimization and prediction
  b <- proximalH(groups, nc, xtest, mtrain, ytest, b, xtrain, ytrain_demean, mu, tol, L, 0, soft_threshold)
  
  xoos <- as.matrix(xoos)
  xtrain <- as.matrix(xtrain)
  
  yhatbig1 <- xoos %*% b + mtrain
  r2_oos[modeln] <- 1 - sum((yhatbig1 - yoos)^2) / sum((yoos - mtrain)^2)
  
  yhatbig1 <- xtrain %*% b + mtrain
  r2_is[modeln] <- 1 - sum((yhatbig1 - ytrain)^2) / sum((ytrain - mtrain)^2)
  
  # Save the coefficients
  pathb <- paste0(title, "/B/b", mo, "_", M, "_", modeln, ".csv")
  write.csv(b, file = pathb, row.names = FALSE)
  
  # Display the R-squared value
  cat(paste("Simple OLS+H R2 : ", round(r2_oos$modeln, 3), "\n"))
  
  
  
  
}


