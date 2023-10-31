library(RSocrata)

read_data_from_csv <- function(file_path) {
  # Vérifier si le fichier existe
  if (!file.exists(file_path)) {
    cat("Le fichier spécifié n'existe pas.\n")
    return(NULL)
  }
  
  # Lire les données à partir du fichier CSV
  data <- read.csv(file_path)
  
  return(data)
}

# Function to read and preprocess the data
read_and_preprocess_data <- function() {
  
  data <- read.socrata("https://data.nasa.gov/resource/gh4g-9sfh.json")
  # data <- read_data_from_csv("Meteorite_Landings.csv")
  
  # data <- tryCatch({
  #   return(read.socrata("https://data.nasa.gov/resource/gh4g-9sfh.json"))
  # }, error = function(e) {
  #   return(read_data_from_csv("Meteorite_Landings.csv"))
  # })
  
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
}
