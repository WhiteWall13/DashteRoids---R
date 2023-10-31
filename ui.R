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
      menuItem("Data Table", tabName = "table", icon = icon("table")),
      menuItem("Pie Chart", tabName = "pie", icon = icon("chart-pie")),
      menuItem("Line Chart", tabName = "line", icon = icon("line-chart")),
      menuItem("Histogram", tabName = "histogram", icon = icon("bar-chart")),
      menuItem("Map", tabName = "map", icon = icon("map-pin"))
    )
  ),
  dashboardBody(
    tabItems(
      # Onglet Pie Chart
      tabItem(
        tabName = "pie",
        fluidRow(
          uiOutput("slider_num_classes"),  # Add the Pie Chart slider
          plotlyOutput("pie_chart")
        )
      ),
      # Onglet Line Chart
      tabItem(
        tabName = "line",
        fluidRow(
          uiOutput("slider_year_range_linechart"),  # Add the Line Chart slider
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
      # Onglet Histogram
      tabItem(
        tabName = "histogram",
        fluidRow(
          plotlyOutput("histogram_chart")
        )
      ),
      # Onglet Map
      tabItem(
        tabName = "map",
        fluidRow(
          uiOutput("slider_year_range_map"),
          uiOutput("dropdown_layer_map"),
          uiOutput("dropdown_color_map"),
          plotlyOutput("map_chart")
        )
      )
    )
  )
)
