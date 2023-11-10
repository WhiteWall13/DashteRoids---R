# Function to install if missing
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}


# Function to get the continent from coordinates
coords2continent <- function(points) {
  countriesSP <- getMap(resolution = 'low')
  
  # Converting points to a SpatialPoints object
  # Setting CRS directly to that from rworldmap
  pointsSP <- SpatialPoints(points, proj4string = CRS(proj4string(countriesSP)))
  
  # Use 'over' to get indices of the Polygons object containing each point
  indices <- over(pointsSP, countriesSP)
  
  return(indices$REGION)
}


# Function to draw a scatter mapbox
draw_scatter_mapbox <- function(gdf, color = "ylorrd_r", layer = "open-street-map", year_range, mapboxToken = "pk.eyJ1IjoibmhtdTEzIiwiYSI6ImNsbXM2aGEwYzA4NGwybXFjZDJtOHlyaWEifQ.rdnzYlRTnPtugsB94ffiNQ") {
  # Remove rows with missing values
  gdf <- gdf[!is.na(gdf$mass), ]
  gdf <- gdf[!is.na(gdf$reclat), ]
  gdf <- gdf[!is.na(gdf$reclong), ]
  
  # Filter
  gdf <- gdf[gdf$year_numeric >= year_range[1] & gdf$year_numeric <= year_range[2], ]
  
  # Create the scatter mapbox plot
  map <- plot_ly(data = gdf,
                 lat = ~gdf$reclat,
                 lon = ~gdf$reclong,
                 type = 'scattermapbox',
                 text = ~gdf$name,
                 marker = list(size = ~gdf$power_mass, sizemode = 'diameter', color = ~gdf$year, colorscale = color),
                 customdata = ~paste("Name: ", gdf$name, "<br>Mass (g): ", gdf$mass, "<br>Year: ", gdf$year)) %>%
    layout(mapbox = list(style = layer, center = list(lon = 0, lat = 40), zoom = 0.5))
  
  # Bug
  # Configure Mapbox token
  # map <- config(map, mapboxAccessToken = mapboxToken)
  
  # Return the plot
  return(map)
}