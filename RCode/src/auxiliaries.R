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


save_plot_two_portfolios <- function(labels, eq, eq2, title, plot_dir = '../plots/'){
  plot <- plot_two_portfolios(labels, eq, eq2)
  
  # Generate a timestamp for the filename
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  
  # Create the full filename, including path, name, timestamp, and extension
  filename <- paste0(plot_dir, title, timestamp, ".png")
  
  # Save the plot
  ggsave(filename, plot = plot, width = 10, height = 6)
}



# This function is created in case that a random data frame is needed it.
random_df <- function(len){
  df <- data.frame(
    x1 = runif(len, 0, 100),
    x2 = runif(len, 0, 100),
    x3 = runif(len, 0, 100),
    x4 = runif(len, 0, 100),
    Y = factor(rbinom(len, 1, 0.5)) # binary target
  )
  return(df)
}