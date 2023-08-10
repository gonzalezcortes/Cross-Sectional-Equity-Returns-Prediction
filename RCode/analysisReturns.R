#Analysis of the Returns using the returns predictions.
library(rstudioapi)
current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path )) #set path
source('src/sampleSplitting.R') # to filter the data
source('src/metrics.R') # To get metric, R2

## Load data ##
actual_model <- as.data.frame(read.csv(file = "../results/actual_testing_values.csv", header = TRUE))
model_x <- as.data.frame(read.csv(file = "../results/model_x_predictions.csv", header = TRUE))

## Get the identifier of the stock
stocks <- unique(actual_model$Stock)

# Get the R2 for each stock as De Nard (2022)
index <- 1
r2_results <- c()

for (stock in stocks) {
    #filter the data according the stock
    model_x_filtered <- filter_by_stock(model_x, stock)
    actual_model_filtered <- filter_by_stock(actual_model, stock)
    
    #calculate the R2
    r2Stock <- r2_metric(model_x_filtered$Values, actual_model_filtered$Values)
    
    #Add the results to a list
    r2_results <- c(r2_results, r2Stock)
    index <- index + 1
    
}

mean(r2_results)


#library(ggplot2)

# If r2_results is a numeric vector, you can convert it to a data frame
#r2_results <- data.frame(value = r2_results)

# Create the plot
#plot <- ggplot(r2_results, aes(x = 1, y = value)) + 
    #geom_violin() +
    #geom_boxplot(width = 0.1) +
    #labs(title = "Violin Boxplot of r2_results", 
         #x = "Variable",
         #y = "Value")

# Display the plot
#plot


library(vioplot)
vioplot(r2_results, names="r2_results", col="gold")























