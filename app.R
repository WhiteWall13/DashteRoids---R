source("functions.R")
install_if_missing("shiny")
install_if_missing("shinydashboard")
install_if_missing("plotly")

source("server.R")
source("ui.R")
library(shiny)
library(shinydashboard)


# App
shinyApp(ui = ui, server = server)