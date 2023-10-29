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
          uiOutput("slider_num_classes"),  # Add the Pie Chart slider
          plotlyOutput("pie_chart")
        )
      ),
      # Onglet Line Chart
      tabItem(
        tabName = "line",
        fluidRow(
          uiOutput("slider_year_range"),  # Add the Line Chart slider
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
