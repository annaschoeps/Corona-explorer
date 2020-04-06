# Load packages ----
library(shiny)
library(ggplot2)
library(tidyverse)
library(plyr)
library(dplyr)
library(plotly)
library(scales)

# Source helpers ----
source("helpers.R")




# User interface ----
ui <- fluidPage(
  
  titlePanel(""),
  
  sidebarLayout(
    
    
    sidebarPanel(
      
      selectizeInput("countries", label ="Choose a country", choices = data2$countriesAndTerritories),
      
      selectizeInput("countries2", label = "Choose a country", choices = data2$countriesAndTerritories),
      
      dateRangeInput("date", label = "Date range"),
      
      checkboxInput("cumulative", label = "Cumulative number of cases"),
      
      checkboxInput("logarithmicScale", label = "Logarithmic scale")
   
    ),
    
    

    
    
    mainPanel(
   plotOutput("mainpanelplot")       
    )
    
    
    )
  
)

# Server logic

server <- function(input, output){
  
  




 
# filters data (input$countries & input$date)  
  countrydata <- reactive({
    filter(data2,
           countriesAndTerritories == input$countries,
           dateRep >= input$date[1],
           dateRep <= input$date[2]
           )
  })
    
  # filters data (input$countries2 & input$date)   
  countrydata2 <- reactive({
    filter(data2,
           countriesAndTerritories == input$countries2,
           dateRep >= input$date[1],
           dateRep <= input$date[2]
    )
  })
  
  
  
  
#adds cumulative cases to countrydata
  countrydataCumsum <- reactive({
    countrydata() %>%
      arrange(dateRep) %>%
      mutate(cumsumCases = cumsum(cases))
  })

 
  
#adds cumulative cases to countrydata2   
  countrydataCumsum2 <- reactive({
    countrydata2() %>%
      arrange(dateRep) %>%
      mutate(cumsumCases = cumsum(cases))
  })
  
  
  

#TODO:
#
#
#
  
  
  
  output$mainpanelplot <- renderPlot({
    
    p = ggplot() 
    
    if (input$cumulative) {
      p = p +
        geom_line(data = countrydataCumsum(), aes(x = dateRep, y = cumsumCases, color = countriesAndTerritories)) +
        geom_line(data = countrydataCumsum2(), aes(x = dateRep, y = cumsumCases, color = countriesAndTerritories)) +
        geom_point(data = countrydataCumsum(), aes(x = dateRep, y = cumsumCases, color = countriesAndTerritories)) +
        geom_point(data = countrydataCumsum2(), aes(x = dateRep, y = cumsumCases, color = countriesAndTerritories)) +
        ylab("Cumulative number of cases")
    } else {
      p = p +
        geom_line(data = countrydata(), aes(x = dateRep, y = cases, color = countriesAndTerritories)) +
        geom_line(data = countrydata2(), aes(x = dateRep, y = cases, color = countriesAndTerritories)) +
        geom_point(data = countrydata(), aes(x = dateRep, y = cases, color = countriesAndTerritories)) +
        geom_point(data = countrydata2(), aes(x = dateRep, y = cases, color = countriesAndTerritories)) +
        ylab("Number of new cases") 
    }
    
    if (input$logarithmicScale){
      p = p +
        scale_y_continuous(trans = 'log10')
    } else {
      p = p +
        scale_y_continuous(breaks = pretty_breaks())
    }
    
    p = p +
      expand_limits(y = 0) +
      xlab("Date") +
      theme_bw()
    
    p
    
    
  })  
  

}





# Run the app ----
shinyApp(ui = ui, server = server)
  
  
  


















#Auswahl in Box:
#selectizeInput("countries","countriesandTerritories", choices = NULL),
  

#server <- function(input, output, session) {
 # updateSelectizeInput(session, 'countries',
  #                     choices = data$countriesAndTerritories,
   #                    server = TRUE)
#}