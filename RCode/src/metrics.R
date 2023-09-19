#This script contains functions to calculate metrics of performance.

# Regular R2 metric
r2_metric <- function(predicted, actual){
  rss <- sum((predicted - actual) ^ 2)
  tss <- sum((actual - mean(actual)) ^ 2)
  r_squared <- 1 - rss/tss
  return(r_squared)
}

## Extracted from gu et al (2020)
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

monthly_stock_level_prediction_performance <- function(predicted_df){
  #Date Stock    Values
  months <- unique(as.Date(predicted_df$Date))
  stocks <- unique(predicted_df$Stock)
  roos_i_array <- c()

  for (stock in stocks){
    
      predicted_df_filtered <- predicted_df %>% filter(Stock %in% stock)
      #actual_df_filtered <- actual_df %>% filter(Stock %in% stock)
      roos_i <- rsq(predicted_df_filtered$Prediction, predicted_df_filtered$Actual)
      
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

calculate_cumulative_log_returns_with_dates <- function(returns, dates) {
  log_returns <- log(1 + returns)
  
  cumulative_log_Returns <- cumsum(log_returns)
  
  merged_df <- data.frame(cumulative_log_Returns = cumulative_log_Returns, dates = dates)
  
  return(merged_df)
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

zero_net_portfolio_a <- function(predicted_returns){
  
  # Check the structure of the data frame
  
  # Unique months from the data
  
  #predicted_returns$Date <- as.Date(predicted_returns$Date, format="%Y-%m-%d")
  
  print(class(predicted_returns$Date[1]))
  months <- unique(predicted_returns$Date)
  print(class(months[1]))
  
  print(class(months[1]))
  

  #holdings <- list(buy = list(), sell = list())
  #list_holding <- c()
  a_returns <- c()

  
  for (i in seq_along(months)){
    month <- months[i]
    
    df_filtered <- predicted_returns %>% filter(Date %in% month)
    
    ### Get deciles ###
    deciles <- calculate_deciles(df_filtered$Stock, df_filtered$Prediction)
    #print(deciles)
    
    #get buy and sell portfolio 
    to_buy <- which(deciles$Deciles == 10)  
    to_sell <- which(deciles$Deciles == 1)
    
    holdings_long <- deciles$Stock[to_buy]
    #print(holdings_long)
    
    ### Get returns ###
    #actual_filtered <- actual_returns %>% filter(Date %in% month)
    returns_holding <- df_filtered  %>% filter(Stock %in% holdings_long) #actual_values
    #print(unique(returns_holding$Stock))
    #print(returns_holding)
    
    print(paste0(month," - ",mean(returns_holding$Actual)))
    a_returns <- c(a_returns, mean(returns_holding$Actual))
    
  }
  return(calculate_cumulative_log_returns(a_returns))
  #return(calculate_cumulative_log_returns(a_returns))
}

######## Septiembre ###########

calculate_equally_weighted_portfolio <- function(actual_values) {
  # Compute the number of unique stocks
  num_stocks <- n_distinct(actual_values$Stock)
  
  # Compute the equal weight for each stock
  equal_weight <- 1 / num_stocks
  
  # Calculate the portfolio value for each date
  portfolio_values <- actual_values %>%
    group_by(Date) %>%
    summarise(Portfolio_Value = sum(Values * equal_weight))
  
  return(portfolio_values)
}





zero_net_portfolio <- function(predicted_returns) {
  
  # Calculate deciles for each date and stock
  deciles <- predicted_returns %>%
    group_by(Date) %>%
    mutate(Decile = ntile(Prediction, 10)) %>%
    ungroup()
  
  print("deciles")
  print(deciles)
  
  # Identify which stocks to buy (Decile = 10)
  ###to_buy <- deciles %>% filter(Decile == 10)
  df_filtered <- deciles
  ### Get deciles ###
  deciles <- calculate_deciles(df_filtered$Stock, df_filtered$Prediction)
  #print(deciles)
  
  #get buy and sell portfolio 
  to_buy <- which(deciles$Deciles == 10)  
  to_sell <- which(deciles$Deciles == 1)
  
  holdings_long <- deciles$Stock[to_buy]
  
  print("to buy")
  print(to_buy)
  
  # Calculate mean returns for each unique date based on selected stocks to buy
  mean_returns_by_date <- to_buy %>%
    group_by(Date) %>%
    summarize(Mean_Return = mean(Actual, na.rm = TRUE)) %>%
    ungroup()
  
  # Calculate cumulative log returns
  print(mean_returns_by_date)
  cumulative_log_returns <- calculate_cumulative_log_returns(mean_returns_by_date$Mean_Return)
  
  # Optional: Add dates to the cumulative log returns
  result <- data.frame(
    Date = mean_returns_by_date$Date,
    Cumulative_Log_Returns = cumulative_log_returns
  )
  
  return(result)
}

# Don't forget to define your calculate_cumulative_log_returns function if it's not already defined
calculate_cumulative_log_returns = function(mean_returns) {
  log_returns <- log(1 + mean_returns)
  cumulative_log_returns <- cumsum(log_returns)
  return(cumulative_log_returns)
}

# Example usage (you'll need to provide your own `predicted_returns` data frame)
# result <- zero_net_portfolio(predicted_returns)


# Example usage (you'll need to provide your own `predicted_returns` and `actual_returns` data frames)
# result <- zero_net_portfolio(predicted_returns, actual_returns)



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


