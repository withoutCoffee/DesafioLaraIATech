# install.packages(c(
#   "gapminder", "ggforce", "gh", "globals", "openintro", "profvis", 
#   "RSQLite", "shiny", "shinycssloaders", "shinyFeedback", 
#   "shinythemes", "testthat", "thematic", "tidyverse", "vroom", 
#   "waiter", "xml2", "zeallot" 
# ))
# 
# install.packages("shiny")
library(shiny)
source("Q1.R")

ui = fluidPage(
  titlePanel("DASHBOARD FINANCEIRO"),
  textInput("ticker","Nome do ticker"),
  actionButton("goButton", "Go!", class = "btn-success"),
  
  hr(),
  tableOutput("info"),
  fluidRow(
    column(6,
           plotOutput("plot_close")
    ),
    column(6,
           plotOutput("plot_volume")
    )
  ),
  tableOutput("key_emps")
)

server = function(input, output, session){
  prices = reactiveValues(data = 0)
  
  info = reactiveValues(data = NULL)
  emp = reactiveValues(data = NULL)
  
  observeEvent(input$goButton,{
    prices$data = get_lastday_month_price(input$ticker)
    info$data = get_company_data(input$ticker)
    emp$data = get_employers(input$ticker)
  })
  
  output$plot_close = renderPlot({
    if(prices$data == 0){
      return(0)
    }
    plot(prices$data$date,prices$data$close)
  })
  output$plot_volume = renderPlot({
    if(prices$data == 0){
      return(0)
    }
    plot(prices$data$date,prices$data$volume)
  })
  
  output$info = renderTable({
    info$data
  })
  
  output$key_emps = renderTable({
    emp$data
  })
  
}
shinyApp(ui,server)