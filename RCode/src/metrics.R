
r2 <- function(predicted, actual){
  rss <- sum((predicted - actual) ^ 2)
  tss <- sum((actual - mean(actual)) ^ 2)
  r_squared <- 1 - rss/tss
  return(r_squared)
}