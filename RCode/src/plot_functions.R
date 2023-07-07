library(ggplot2)

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

plot_two_portfolios <- function(labels, eq, eq2){
  df <- data.frame(index = 1:length(eq), value = eq, value2 = eq2)
  
  ggplot(df, aes(x = index)) +
    geom_line(aes(y = value, colour = labels[1])) +
    geom_line(aes(y = value2, colour = labels[2])) +
    labs(x = "Year", 
         y = "Cumulative Log Return", 
         title = "Cumulative Portfolio", 
         colour = "Portfolio") +
    scale_x_continuous(breaks = seq(from = 13, to = max(df$index), by = 24), 
                       labels = seq(from = 1998, to = 2016, by = 2)) +
    theme(legend.position = "bottom", 
          legend.background = element_rect(fill = "white", colour = "black"), 
          legend.box.background = element_rect(colour = "black"))
}