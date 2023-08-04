

r2_old <- function(predicted, actual){
  rss <- sum((predicted - actual) ^ 2)
  tss <- sum((actual - mean(actual)) ^ 2)
  r_squared <- 1 - rss/tss
  return(r_squared)
}

r2 <- function(predicted, actual, mtrain){
    #mtrain is the mean(ytrain)
    
    r_squared = 1 - sum((predicted - actual)^2) / sum((actual - mtrain)^2)
    

    return(r_squared)
}


rsq <- function (x, y) cor(x, y) ^ 2

r2PerYear <- function(predicted_df, actual_df, years){
  r2_a <- c()
  for (year in years){
    print(year)
    actual_filtered <- actual_df %>% filter(format(Date, "%Y") %in% c(year))
    m_filtered <- predicted_df %>% filter(format(Date, "%Y") %in% c(year))
    r2_a <- c(r2_a, r2(m_filtered$Values, actual_filtered$Values))
  }
  
  print(summary(r2_a))
}

monthly_stock_level_prediction_performance <- function(predicted_df, actual_df){
  #Date Stock    Values
  months <- unique(as.Date(predicted_df$Date))
  stocks <- unique(predicted_df$Stock)
  roos_i_array <- c()

  for (stock in stocks){
    
      predicted_df_filtered <- predicted_df %>% filter(Stock %in% stock)
      actual_df_filtered <- actual_df %>% filter(Stock %in% stock)
      roos_i <- rsq(predicted_df_filtered$Values, actual_df_filtered$Values)
      
      roos_i_array <- c(roos_i_array, roos_i)
  }
  print(summary(roos_i_array))
}


#### Portfolio metrics ####

calculate_cumulative_log_returns = function(mean_returns) {
  log_returns <- log(1 + mean_returns)
  cumulative_log_returns <- cumsum(log_returns)
  return(cumulative_log_returns)
}




calculate_deciles <- function(labels, returns) {
  data <- data.frame(returns)
  deciles <- lapply(data, function(x) {
    x_ranks <- rank(x, ties.method = "first")
    cut(x_ranks, quantile(x_ranks, probs=0:10/10), include.lowest=TRUE, labels=FALSE)
    #cut(x, breaks = quantile(x, probs = seq(0, 1, by = 0.1)), include.lowest = TRUE, labels = FALSE)
  })
  deciles_matrix <- do.call(cbind, deciles)  # Convert list to matrix
  deciles_df <- data.frame(Stock = labels, deciles_matrix)
  names(deciles_df)[-1] <- "Deciles"# Rename
  
  return(deciles_df)
}

buy_sell <- function(pred_returns) {
  deciles <- calculate_deciles(pred_returns)
  
  holdings <- list(buy = list(), sell = list())
  
  for (day in 1:ncol(deciles)) {
    to_buy <- which(deciles[, day] == 10)  # Decile 10 (1-indexed)
    to_sell <- which(deciles[, day] == 1)  # Decile 1
    holdings$buy[[day]] <- to_buy
    holdings$sell[[day]] <- to_sell
  }
  
  return(holdings)
}

####     Portfolio construction    ####


equally_weighted_portfolio <- function(returns){
  months <- unique(as.Date(returns$Date))
  a_returns <- c()
  for (month in months){
    month <- as.Date(month)
    df_filtered <- returns %>% filter(Date %in% month)
    #print(df_filtered)
    print(paste0(month," - " ,mean(df_filtered$Values)))
    a_returns <- c(a_returns, mean(df_filtered$Values))
  }
  return(calculate_cumulative_log_returns(a_returns))
}

zero_net_portfolio <- function(actual_returns, predicted_returns){
  months <- unique(as.Date(predicted_returns$Date))
  #holdings <- list(buy = list(), sell = list())
  #list_holding <- c()
  a_returns <- c()
  for (month in months){
    month <- as.Date(month)
    
    df_filtered <- predicted_returns %>% filter(Date %in% month)
    
    ### Get deciles ###
    deciles <- calculate_deciles(df_filtered$Stock, df_filtered$Values)
    #print(deciles)
    
    #get buy and sell portfolio 
    to_buy <- which(deciles$Deciles == 10)  
    to_sell <- which(deciles$Deciles == 1)
    
    holdings_long <- deciles$Stock[to_buy]
    #print(holdings_long)
    
    ### Get returns ###
    actual_filtered <- actual_returns %>% filter(Date %in% month)
    returns_holding <- actual_filtered  %>% filter(Stock %in% holdings_long) #actual_values
    #print(unique(returns_holding$Stock))
    #print(returns_holding)
    
    print(paste0(month," - ",mean(returns_holding$Values)))
    a_returns <- c(a_returns, mean(returns_holding$Values))
    
  }
  return(calculate_cumulative_log_returns(a_returns))
  #return(calculate_cumulative_log_returns(a_returns))
}


######## Sin usar ########
a <- c("a1","b1","c1","d1","e1","f1","g1","f1","h1")
b <- c(80,20,30,40,50,0,60,80,100)

d1 <- data.frame("a" = a, "b" = b)
d2 <- calculate_deciles(d1$a, d1$b)
#print(d2)

#to_buy <- which(d2$returns == 10)
#d1$a[to_buy]

#holdings <- list(buy = list(), sell = list())

#holdings$buy[["Lunes"]] <- to_buy
#holdings$buy[["Lunes"]] <- c(3,6)
#holdings$buy[["Martes"]] <- to_buy

#holdings


