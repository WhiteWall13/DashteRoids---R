library(shiny)
library(DT)
library(plotly)
source("data.R")
library(countrycode)
library(httr)
library(sp)
library(rworldmap)
library(dplyr)


# Fonction pour obtenir le continent à partir des coordonnées géographiques
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


# Charger les données
data <- read_and_preprocess_data()


mapboxToken <- "pk.eyJ1IjoibmhtdTEzIiwiYSI6ImNsbXM2aGEwYzA4NGwybXFjZDJtOHlyaWEifQ.rdnzYlRTnPtugsB94ffiNQ"

draw_scatter_mapbox <- function(gdf, color = "ylorrd_r", layer = "basic", year_range) {
  cat(color)
  # Supprimer les lignes avec des valeurs de masse manquantes
  gdf <- gdf[!is.na(gdf$mass), ]
  
  gdf <- gdf[gdf$year_numeric >= year_range[1] & gdf$year_numeric <= year_range[2], ]

  # Créer le graphique scatter mapbox
  map <- plot_ly(data = gdf,
                 lat = ~gdf$reclat,
                 lon = ~gdf$reclong,
                 type = 'scattermapbox',
                 text = ~gdf$name,
                 marker = list(size = ~gdf$power_mass, sizemode = 'diameter', color = ~gdf$year, colorscale = color),
                 customdata = ~paste("Name: ", gdf$name, "<br>Mass (g): ", gdf$mass, "<br>Year: ", gdf$year)) %>%
    layout(mapbox = list(style = layer, center = list(lon = 0, lat = 40), zoom = 0.5))

  # Configurer le jeton Mapbox
  map <- config(map, mapboxAccessToken = mapboxToken)

  print(class(map))
  str(map)
  
  
  
  
  # Retourner le graphique
  return(map)
}

# Function to create the Shiny server
server <- function(input, output) {

  # Slider for the number of classes (Pie Chart)
  output$slider_num_classes <- renderUI({
    sliderInput("num_classes", "Select the number of classes to display:",
                min = 1, max = 466, value = 10, step = 1, ticks = TRUE)
  })

  # Slider for the year range (Line Chart)
  output$slider_year_range_linechart <- renderUI({
    sliderInput("year_range_linechart", "Choose the year range:",
                min = min(data$year_numeric, na.rm = TRUE), max = max(data$year_numeric, na.rm = TRUE),
                value = c(min(data$year_numeric, na.rm = TRUE), max(data$year_numeric, na.rm = TRUE)), step = 1)
  })

  # Slider for the year range (Map)
  output$slider_year_range_map <- renderUI({
    sliderInput("year_range_map", "Choose the year range:",
                min = min(data$year_numeric, na.rm = TRUE), max = max(data$year_numeric, na.rm = TRUE),
                value = c(min(data$year_numeric, na.rm = TRUE), max(data$year_numeric, na.rm = TRUE)), step = 1)
  })
  
  output$dropdown_layer_map <- renderUI({
    selectInput("layer_map", "Choose a map layer :",
                choices = c("basic", "streets", "outdoors", "light", "dark", "satellite",
                            "satellite-streets", "open-street-map", "carto-positron", "carto-darkmatter",
                            "stamen-terrain", "stamen-toner", "stamen-watercolor"),
                selected = "basic")
  })
  
  output$dropdown_color_map <- renderUI({
    selectInput("color_map", "Choose a map color :",
                choices = c('aggrnyl', 'agsunset', 'blackbody', 'bluered', 'blues', 'blugrn', 'bluyl', 'brwnyl', 'bugn', 'bupu', 'burg', 'burgyl', 'cividis', 'darkmint', 'electric', 'emrld', 'gnbu', 'greens', 'greys', 'hot', 'inferno', 'jet', 'magenta', 'magma', 'mint', 'orrd', 'oranges', 'oryel', 'peach', 'pinkyl', 'plasma', 'plotly3', 'pubu', 'pubugn', 'purd', 'purp', 'purples', 'purpor', 'rainbow', 'rdbu', 'rdpu', 'redor', 'reds', 'sunset', 'sunsetdark', 'teal', 'tealgrn', 'turbo', 'viridis', 'ylgn', 'ylgnbu', 'ylorbr', 'ylorrd', 'algae', 'amp', 'deep', 'dense', 'gray', 'haline', 'ice', 'matter', 'solar', 'speed', 'tempo', 'thermal', 'turbid', 'armyrose', 'brbg', 'earth', 'fall', 'geyser', 'prgn', 'piyg', 'picnic', 'portland', 'puor', 'rdgy', 'rdylbu', 'rdylgn', 'spectral', 'tealrose', 'temps', 'tropic', 'balance', 'curl', 'delta', 'oxy', 'edge', 'hsv', 'icefire', 'phase', 'twilight', 'mrybm', 'mygbm'),
                selected = "ylorrd")
  })

  output$data_table <- renderDataTable({
    data_subset <- data[, 1:9]
    datatable(data_subset)
  })

  output$line_chart <- renderPlotly({
    filtered_data <- data[data$year_numeric >= input$year_range_linechart[1] & data$year_numeric <= input$year_range_linechart[2], ]
    meteorites_per_year <- table(filtered_data$year)
    dfy <- data.frame(year = as.numeric(names(meteorites_per_year)), value = as.numeric(meteorites_per_year))
    dfy <- dfy[order(dfy$year), ]
    line_chart <- plot_ly(dfy, x = ~year, y = ~value, type = 'scatter', mode = 'lines+markers')
    line_chart <- line_chart %>% layout(title = "Number of meteorites per year")
    return(line_chart)
  })

  output$pie_chart <- renderPlotly({
    recclass_counts <- table(data$recclass)
    sorted_counts <- sort(recclass_counts, decreasing = TRUE)
    selected_counts <- sorted_counts[1:min(input$num_classes, length(sorted_counts))]
    data_to_plot <- data.frame(Class = names(selected_counts), Count = as.numeric(selected_counts))
    pie_chart <- plot_ly(data_to_plot, labels = ~Class, values = ~Count, type = 'pie', hole = 0.4, textposition = 'inside', textinfo = 'label+percent')
    pie_chart <- pie_chart %>% layout(title = "Distribution of meteorite classes")
    return(pie_chart)
  })
  
  output$histogram_chart <- renderPlotly({
    # Filtrer les lignes avec des coordonnées non manquantes
    data_hist <- data[!is.na(data$reclat) & !is.na(data$reclong), ]
    
    # Fonction pour obtenir le continent à partir des coordonnées géographiques
    coordinates <- data.frame(lon = data_hist$reclong, lat = data_hist$reclat)
    data_hist$continent <- coords2continent(coordinates)
    
    # Groupez par "continent" et créez l'histogramme
    grouped_data <- data_hist %>% group_by(continent) %>% summarise(Count = n())
    chart_title <- "Number of meteorites per continent"
    
    # Créez l'histogramme
    histogram_chart <- plot_ly(grouped_data, x = ~continent, y = ~Count, type = 'bar')
    histogram_chart <- histogram_chart %>% layout(title = chart_title)
    
    return(histogram_chart)
  })
  
  # Fonction pour créer le graphique Mapbox
  output$map_chart <- renderPlotly({
    gdf <- data

    # color <- input$color_map
    map <- draw_scatter_mapbox(gdf, layer = input$layer_map, year_range = input$year_range_map)

    return(map)
  })

}