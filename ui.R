source("functions.R")
install_if_missing("shiny")
install_if_missing("shinydashboard")
install_if_missing("plotly")
install_if_missing("shinyjs")

library(shiny)
library(shinydashboard)
library(plotly)
library(shinyjs)
source("server.R")

# UI
ui <- dashboardPage(
  dashboardHeader(title = "DashteRoids"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data Table", tabName = "table", icon = icon("table")),
      menuItem("Histogram and Line Chart", tabName = "line", icon = icon("line-chart")),
      menuItem("Pie Chart", tabName = "pie", icon = icon("chart-pie")),
      menuItem("Bar chart", tabName = "bar_chart", icon = icon("bar-chart")),
      menuItem("Map", tabName = "map", icon = icon("map-pin"))
    )
  ),
  dashboardBody(
    tabItems(
      # Onglet Pie Chart
      tabItem(
        tabName = "pie",
        fluidRow(
          uiOutput("slider_num_classes"),
          plotlyOutput("pie_chart"),
          verbatimTextOutput("piechart_text_output")
        )
      ),
      # Onglet Line Chart and Histogram
      tabItem(
        tabName = "line",
        fluidRow(
          selectInput("chart_type", "Select Chart Type", choices = c("Histogram", "Line Chart"), selected = "Histogram"),
          uiOutput("slider_year_range"),
          plotlyOutput("line_chart"),
          plotlyOutput("histogram_chart"),
          verbatimTextOutput("linechart_text_output")
        )
      ),
      # Onglet Data Table
      tabItem(
        tabName = "table",
        fluidRow(
          dataTableOutput("data_table"),
          verbatimTextOutput("datatable_text_output")
        )
      ),
      # Onglet Bar Chart
      tabItem(
        tabName = "bar_chart",
        fluidRow(
          plotlyOutput("bar_chart"),
          verbatimTextOutput("bar_text_output")
        )
      ),
      # Onglet Map
      tabItem(
        tabName = "map",
        fluidRow(
          uiOutput("slider_year_range_map"),
          uiOutput("dropdown_layer_map"),
          plotlyOutput("map_chart"),
          verbatimTextOutput("map_text_output")
        )
      )
    )
  )
)
