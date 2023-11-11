source("functions.R")
install_if_missing("shiny")
install_if_missing("DT")
install_if_missing("plotly")
install_if_missing("countrycode")
install_if_missing("httr")
install_if_missing("sp")
install_if_missing("rworldmap")
install_if_missing("dplyr")

source("data/data.R")
library(shiny)
library(DT)
library(plotly)
library(countrycode)
library(httr)
library(sp)
library(rworldmap)
library(dplyr)

# Load the data
data <- read_and_preprocess_data()

# Texts
datatable_text = "The data table provides a detailed and sortable view of the meteorite landings. It serves as a foundational tool for researchers and enthusiasts alike, offering a granular look at each individual event. This table is the gateway to deeper insights and is the basis for all subsequent visual analyses."
piechart_text = "The pie chart of meteorite classes reveals the distribution of various types of meteorites. The prominence of certain classes over others can be attributed to a combination of factors, including the frequency of these types in space, their survival rate through Earth's atmosphere, and the ease with which they can be found and identified on Earth's surface."
linechart_text = "Those histogram, line chart and cumulative sum charts depict the distribution of meteorite landings over the years, showing both the total count and the cumulative count. The scarcity of data in earlier years can be attributed to factors such as less systematic data recording, reduced efforts in meteorite searches, and the natural erosion and gradual disappearance of older meteorites, making their identification increasingly challenging as time passes."
bar_text = "The bar chart displaying the number of meteorites found per continent highlights intriguing geographical patterns. The high numbers in Antarctica and Africa could be influenced by the visibility and preservation conditions in desert and ice environments, which are conducive to meteorite recovery. The size of the continent, human population density, and the extent of scientific exploration also play significant roles in these figures."
map_text = "The scatter map and density visualization provide a spatial perspective of meteorite landings. The absence of meteorites in aquatic regions is not indicative of their actual fall patterns but rather reflects the difficulty in locating and retrieving meteorites from these environments."

# Function to create the Shiny server
server <- function(input, output) {
  
  # Slider for the number of classes (Pie Chart)
  output$slider_num_classes <- renderUI({
    sliderInput("num_classes", "Select the number of classes to display:",
                min = 1, max = length(unique(data$recclass)), value = 10, step = 1, ticks = TRUE)
  })
  
  # Slider for the year range (Line Chart and Histogram)
  output$slider_year_range <- renderUI({
    sliderInput("slider_year_range", "Choose the year range:",
                min = min(data$year_numeric, na.rm = TRUE), max = max(data$year_numeric, na.rm = TRUE),
                value = c(1969, max(data$year_numeric, na.rm = TRUE)), step = 1)
  })
  
  # Slider for the year range (Map)
  output$slider_year_range_map <- renderUI({
    sliderInput("year_range_map", "Choose the year range:",
                min = min(data$year_numeric, na.rm = TRUE), max = max(data$year_numeric, na.rm = TRUE),
                value = c(1969, max(data$year_numeric, na.rm = TRUE)), step = 1)
  })
  
  # Dropdown menu map
  output$dropdown_layer_map <- renderUI({
    selectInput("layer_map", "Choose a map layer :",
                choices = c("open-street-map", "carto-positron", "carto-darkmatter",
                            "stamen-terrain", "stamen-toner", "stamen-watercolor"),
                selected = "open-street-map")
  })
  
  # DataTable
  output$data_table <- renderDataTable({
    data_subset <- data[, 1:9]
    datatable(data_subset)
  })

  # Display histogram or Line Chart
  output$line_chart <- renderPlotly({
    if (input$chart_type == "Line Chart") {
      # Filter 
      filtered_data <- data[data$year_numeric >= input$slider_year_range[1] & data$year_numeric <= input$slider_year_range[2], ]
      meteorites_per_year <- table(filtered_data$year)
      # Convert
      dfy <- data.frame(year = as.numeric(names(meteorites_per_year)), value = as.numeric(meteorites_per_year))
      # Order By year
      dfy <- dfy[order(dfy$year), ]
      # Chart
      line_chart <- plot_ly(dfy, x = ~year, y = ~value, type = 'scatter', mode = 'lines+markers')
      line_chart <- line_chart %>% layout(title = "Number of meteorites per year")
      return(line_chart)
    } else if (input$chart_type == "Histogram") {
      # Filter 
      filtered_data <- data[data$year_numeric >= input$slider_year_range[1] & data$year_numeric <= input$slider_year_range[2], ]
      meteorites_per_year <- table(filtered_data$year)
      # Convert
      dfy <- data.frame(year = as.numeric(names(meteorites_per_year)), count = as.numeric(meteorites_per_year))
      # Order by year
      dfy <- dfy[order(dfy$year), ]
      
      # Chart
      histogram_chart <- plot_ly(dfy, x = ~year, y = ~count, type = 'bar', text = ~count, textposition = 'inside', textangle = -90)
      histogram_chart <- histogram_chart %>% layout(title = "Distribution of the number of meteorites per year", xaxis = list(type = 'category'))
      
      return(histogram_chart)
    }
  })

  # Pie Chart
  output$pie_chart <- renderPlotly({
    recclass_counts <- table(data$recclass)
    sorted_counts <- sort(recclass_counts, decreasing = TRUE)
    selected_counts <- sorted_counts[1:min(input$num_classes, length(sorted_counts))]
    data_to_plot <- data.frame(Class = names(selected_counts), Count = as.numeric(selected_counts))
    pie_chart <- plot_ly(data_to_plot, labels = ~Class, values = ~Count, type = 'pie', hole = 0.4, textposition = 'inside', textinfo = 'label+percent')
    pie_chart <- pie_chart %>% layout(title = "Distribution of meteorite classes")
    return(pie_chart)
  })
  
  # Bar Chart
  output$bar_chart <- renderPlotly({
    # Remove NA values
    data_hist <- data[!is.na(data$reclat) & !is.na(data$reclong), ]
    
    # Get continent from coordinates
    coordinates <- data.frame(lon = data_hist$reclong, lat = data_hist$reclat)
    data_hist$continent <- coords2continent(coordinates)
    
    # Group datas
    grouped_data <- data_hist %>% group_by(continent) %>% summarise(Count = n())
    
    
    # Bar Chart
    chart_title <- "Number of meteorites per continent"
    bar_chart <- plot_ly(grouped_data, x = ~continent, y = ~Count, type = 'bar')
    bar_chart <- bar_chart %>% layout(title = chart_title)
    
    return(bar_chart)
  })
  
  # Map
  output$map_chart <- renderPlotly({
    map <- draw_scatter_mapbox(data, layer = input$layer_map, year_range = input$year_range_map)
    return(map)
  })
  
  # Texts
  output$piechart_text_output <- renderText({
    piechart_text
  })
  
  output$linechart_text_output <- renderText({
    linechart_text
  })
  
  output$datatable_text_output <- renderText({
    datatable_text
  })
  
  output$bar_text_output <- renderText({
    bar_text
  })
  
  output$map_text_output <- renderText({
    map_text
  })
  
}