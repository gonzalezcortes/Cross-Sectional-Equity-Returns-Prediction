library(ggplot2)

r2 <- function(predicted, actual){
  rss <- sum((predicted - actual) ^ 2)
  tss <- sum((actual - mean(actual)) ^ 2)
  r_squared <- 1 - rss/tss
  return(r_squared)
}

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


calculate_cumulative_log_returns = function(mean_returns) {
  log_returns <- log(1 + mean_returns)
  cumulative_log_returns <- cumsum(log_returns)
  return(cumulative_log_returns)
}

equally_weighted_portfolio <- function(returns){
  months <- unique(as.Date(returns$Date))
  a_returns <- c()
  for (month in months){
    month <- as.Date(month)
    print(month)
    df_filtered <- returns %>% filter(Date %in% month)
    a_returns <- c(a_returns, mean(df_filtered$Values))
  }
  return(calculate_cumulative_log_returns(a_returns))
}


plot_portfolio <- function(eq){
  df <- data.frame(index = 1:length(eq), value = eq)

  ggplot(df, aes(x = index, y = value)) +
    geom_line() +
    labs(x = "Year", 
         y = "Cumulative Log Return", 
         title = "Cumulative Portfolio") +
    scale_x_continuous(breaks = seq(from = 13, to = max(df$index), by = 24), 
                       labels = seq(from = 1998, to = 2016, by = 2))
}

calculate_deciles <- function(pred_returns) {
  data <- data.frame(pred_returns)
  deciles <- lapply(data, function(x) {
    cut(x, breaks = quantile(x, probs = seq(0, 1, by = 0.1)), include.lowest = TRUE, labels = FALSE)
  })
  deciles <- as.data.frame(deciles)
  return(deciles)
}

vc <- c(3,4,1,2,8)
f <- calculate_deciles(vc)
f

