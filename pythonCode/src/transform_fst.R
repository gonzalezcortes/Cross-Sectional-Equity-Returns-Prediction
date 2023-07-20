library(fst)

setwd("G:/My Drive/Research Papers/Cross Sectional 2023/")



# Read the FST file
fst_data <- read_fst("data/data_paths.fst")  # Replace with your FST file path

# Convert the FST data to a data frame
data_frame <- as.data.frame(fst_data)

# Save the data frame as a CSV file
write.csv(data_frame, file = "data/data_paths.csv", row.names = TRUE)

print("done")
