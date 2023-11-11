source("functions.R")
install_if_missing("RSocrata")

library(RSocrata)

read_data_from_csv <- function(file_path) {
  # Check if file eixists
  if (!file.exists(file_path)) {
    cat("The data file doesn't exists.")
    return(NULL)
  }
  
  # Read data from CSV
  data <- read.csv(file_path)
  
  return(data)
}


# Function to read and preprocess the data
read_and_preprocess_data <- function(data) {
  
  data <- tryCatch({
    # Get data
    data = read.socrata("https://data.nasa.gov/resource/gh4g-9sfh.json")
    # Format the data
    data$year <- sub("-.*", "", data$year)
    data$mass <- as.numeric(data$mass)
    data$reclat <- as.numeric(data$reclat)
    data$reclong <- as.numeric(data$reclong)
    current_year <- as.numeric(format(Sys.Date(), "%Y"))
    data$year_numeric <- as.numeric(data$year)
    data$year_numeric[data$year_numeric > current_year] <- NA
    exponent <- 0.2
    data$power_mass <- data$mass^exponent
    return(data)
  }, error = function(e) {
    # Get data
    data = read_data_from_csv("data/file/Meteorite_Landings.csv")
    # Format the data
    data$mass <- as.numeric(data$mass)
    data$reclat <- as.numeric(data$reclat)
    data$reclong <- as.numeric(data$reclong)
    current_year <- as.numeric(format(Sys.Date(), "%Y"))
    data$year_numeric <- as.numeric(data$year)
    data$year_numeric[data$year_numeric > current_year] <- NA
    exponent <- 0.2
    data$power_mass <- data$mass^exponent
    return(data)
  })
}
