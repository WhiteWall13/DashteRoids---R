library(shiny)
library(shinydashboard)
library(plotly)
library(shinyjs)
source("server.R")


# Function to create the Shiny UI
ui <- dashboardPage(
  dashboardHeader(title = "DashteRoids"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data Table", tabName = "table"),
      menuItem("Pie Chart", tabName = "pie"),
      menuItem("Line Chart", tabName = "line"),
      menuItem("Map", tabName = "map", icon = icon("map-pin"))
    )
  ),
  dashboardBody(
    tabItems(
      # Onglet Pie Chart
      tabItem(
        tabName = "pie",
        fluidRow(
          sliderInput("num_classes", "Select the number of classes to display:",
                      min = 1, max = 466, value = 10, step = 1, ticks = TRUE),
          plotlyOutput("pie_chart")
        )
      ),
      # Onglet Line Chart
      tabItem(
        tabName = "line",
        fluidRow(
          # sliderInput("year_range", "Choose the year range:",
          #             min = min(data$year), max = max(data$year), value = c(min(data$year), max(data$year)), step = 1),
          sliderInput("year_range", "Choose the year range:",
                      min = 800, max = 2013, value = c(800, 2013), step = 1),
          plotlyOutput("line_chart")
        )
      ),
      # Onglet Data Table
      tabItem(
        tabName = "table",
        fluidRow(
          dataTableOutput("data_table")
        )
      ),
      tabItem(
        tabName = "map",
        fluidRow(
          plotlyOutput("map_chart")
        )
      )
    )
  )
)
