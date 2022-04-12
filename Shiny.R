# install.packages(c(
#   "gapminder", "ggforce", "gh", "globals", "openintro", "profvis", 
#   "RSQLite", "shiny", "shinycssloaders", "shinyFeedback", 
#   "shinythemes", "testthat", "thematic", "tidyverse", "vroom", 
#   "waiter", "xml2", "zeallot" 
# ))
# 
# install.packages("shiny")
library(shiny)

ui = fluidPage(
  selectInput("dataset",label="Dataset",choice = ls("package:datasets")),
  verbatimTextOutput("summary"),
  plotOutput("plot",width="400px"),
  tableOutput("table")
)

server = function(input, output, session){
  output$summary = renderPrint({
    dataset = get(input$dataset, "package:datasets")
    summary(dataset)
  })
  output$table = renderTable({
    dataset = get(input$dataset, "package:datasets")
    dataset
  })
  output$plot = renderPlot(plot(get(input$dataset,"package:datasets")))
}
shinyApp(ui,server)