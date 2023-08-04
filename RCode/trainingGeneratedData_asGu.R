### This file contains the training of models using generated data ###
### This code is the translation of the code of Gu et al. ###

library(rstudioapi)

# Getting the path of your current open file
current_path = rstudioapi::getActiveDocumentContext()$path

# Set the working directory to the folder containing the script
setwd(dirname(current_path))
path <- getwd()


###############################################################################
###############################################################################

# Huber loss function
# Define the Huber loss function
lossh <- function(y, yhat, mu) {
    r <- abs(yhat - y)
    l <- rep(0, length(r))
    ind <- r > mu
    l[ind] <- 2 * mu * r[ind] - mu^2
    ind <- r <= mu
    l[ind] <- r[ind]^2
    return(mean(l))
}
  
  
  # Define the gradient of the Huber loss
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


###############################################################################
###############################################################################

# Definitions of same variables
M <- 1 #MC
hh <- 1 #%for hh = [1 3 6 12] % correspond to monthly quarterly halfyear and annually returns
    

nump <- 50 #%Or datanum=100; seperately run two cases
mu <- 0.2 * sqrt(hh)

tol <- 1e-10
datanum <- 50

###############################################################################
###############################################################################

for (mo in c(1, 2)) {

  
    # Definition of the title as path to the specific file
    title <- paste(dirname(path), "/SimulatedData/SimuData_p", 
                    as.character(datanum), "/Reg", as.character(hh), sep="")
  
    # Print the model number and MCMC number
    print(paste('### MCMC :', M, ', Model :', mo, ' ###'))
  
    # Set same constants
    N <- 200 # Number of CS tickers
    m <- nump * 2 # Number of Characteristics
    T <- 180 # Number of Time Periods
  
    # Create some variables
    per <- rep(1:N, T)
    time <- rep(1:T, each = N)
    stdv <- 0.05
    theta_w <- 0.005
  
    # Read Files ## Check this path
    path1 <- paste('../SimulatedData/SimuData_p50/c', M,'.csv', sep = '')
    path2 <- paste('../SimulatedData/SimuData_p50/r', mo, '_', M,'.csv', sep = '')

    c <- read.csv(path1)
    r1 <- read.csv(path2)

    # Prepare the Data
    daylen <- rep(N, T / 3)
    daylen_test <- daylen
    ind <- 1:floor(N * T / 3)
  
    # Split data into train and test sets
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
  
    # Demean the training and testing response
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

    # Convert data frames to matrices
    xtrain <- as.matrix(xtrain)
    # colnames(xtrain) <- NULL
    xtest <- as.matrix(xtest)
    # colnames(xtest) <- NULL
    
    # Compute some statistics
    XX <- t(xtrain) %*% xtrain

    svd_res <- svd(XX)
    
    L <- svd_res$d[1]
  
    Y <- ytrain_demean
    XY <- t(xtrain) %*% Y
  
    # Start to Train
    # Train OLS model
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
  
    # Increase the model number
    modeln <- modeln + 1
  
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


