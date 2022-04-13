# install.packages(c(
#   "gapminder", "ggforce", "gh", "globals", "openintro", "profvis", 
#   "RSQLite", "shiny", "shinycssloaders", "shinyFeedback", 
#   "shinythemes", "testthat", "thematic", "tidyverse", "vroom", 
#   "waiter", "xml2", "zeallot" 
# ))
# 
# install.packages("shiny")
library(shiny)
source("handle_data.R")

ui = fluidPage(
  theme = bslib::bs_theme(bootswatch = "flatly"),
  
  titlePanel("DASHBOARD FINANCEIRO"),
  textInput("ticker","Nome do ticker"),
  actionButton("goButton", "Go!", class = "btn-success"),
  
  hr(),
  tableOutput("info"),
  fluidRow(
    column(6,
           textOutput("text1"),
           plotOutput("plot_close")
    ),
    column(6,
           textOutput("text2"),
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
    output$text1 = renderText({
      "Preço fechamento último dia do mês ao longo do tempo"
    })
    
    ggplot(prices$data,aes(x=date,y=close)) +
      geom_point(color="blue") +
      geom_line(color="black") + 
      labs(
        x = "Data",
        y = "Valor Fechamento ($)"
      )
    
  })
  
  output$plot_volume = renderPlot({
    if(prices$data == 0){
      return(0)
    }
    output$text2 = renderText({"Volume de ações vendidas do último dia de cada mês"})
    
    ggplot(prices$data,aes(x=date,y=volume)) +
      geom_point(color="blue") +
      geom_line(colo="black")+
      labs(
        x = "Data",
        y = "Volume"
      )
  })
  
  output$info = renderTable({
    info$data
  })
  
  output$key_emps = renderTable({
    emp$data
  })
  
}
shinyApp(ui,server)