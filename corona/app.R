# Load packages ----
library(shiny)
library(ggplot2)
library(tidyverse)
library(plyr)
library(dplyr)
library(plotly)
library(scales)
library(maps)
library(rworldmap)
library(sf)
library(raster)
library(dplyr)
library(spData)
library(leaflet) # for interactive maps
library(tmap)
library(raster)
library(dplyr)
library(spData)
library(tmap)
library(tmaptools)



# Source helpers ----
source("helpers.R")




# User interface ----
ui <- fluidPage(
  
  titlePanel("Reported cases of coronavirus"),
  
  sidebarLayout(
    
    
    sidebarPanel(
      
      selectizeInput("countries", label ="Choose countries", choices = NULL, selected = NULL, options = list(maxItems = 8)),
      
      dateRangeInput("date", label = "Date range"),
      
      checkboxInput("cumulative", label = "Cumulative number of cases"),
      
      checkboxInput("logarithmicScale", label = "Logarithmic scale")
   
    ),
    
    

    
    
    mainPanel(
   plotOutput("mainpanelplot"),
   plotOutput("worldmap")
    )
    
    
    )
  
)

# Server logic


server <- function(input, output, session){
  

updateSelectizeInput(session, "countries", choices = data2$countriesAndTerritories, server = TRUE)
  
  

 
# filters data (input$countries & input$date)  
  countrydata <- reactive({
    filter(data2,
           countriesAndTerritories %in% input$countries,
           dateRep >= input$date[1],
           dateRep <= input$date[2]
           )
  })
    
  
#adds cumulative cases to countrydata
  countrydataCumsum <- reactive({
    countrydata() %>%
      group_by(countriesAndTerritories) %>%
      arrange(dateRep) %>%
      mutate(cumsumCases = cumsum(cases))
  })

  
  
#Create plot  
  
output$mainpanelplot <- renderPlot({
    
    p = ggplot() 
    
    if (input$cumulative) {
      p = p +
        geom_line(data = countrydataCumsum(), aes(x = dateRep, y = cumsumCases, color = countriesAndTerritories)) +
        geom_point(data = countrydataCumsum(), aes(x = dateRep, y = cumsumCases, color = countriesAndTerritories)) +
        ylab("Cumulative number of cases")
    } else {
      p = p +
        geom_line(data = countrydata(), aes(x = dateRep, y = cases, color = countriesAndTerritories)) +
        geom_point(data = countrydata(), aes(x = dateRep, y = cases, color = countriesAndTerritories)) +
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
      theme_bw() +
      scale_color_brewer(type = "qual", palette = "Dark2")
    
    p
    
  })  
  
#Create map

#filter data: input$date
 dateData <- reactive({data2 %>%
                          group_by(countriesAndTerritories) %>%
                           filter(
                               dateRep >= input$date[1],
                               dateRep <= input$date[2]
                                  ) %>%
                          arrange(dateRep) %>%
                          mutate(cumsumCases = cumsum(cases)) %>%
                          filter(cumsumCases == max(cumsumCases)) %>%
                          ungroup()
 }) 

 
#Create plot

 
 #TODO: dateData: nur DateRep und cumsumCases auswählen, Duplikate entfernen. Dann nochmal leaflet testen
mapData2<- reactive({
   sp::merge(world, dateData(), by.x ="iso_a2", by.y="geoId")
 })


output$worldmap = renderPlot({
   tm_shape(mapData2()) +
   tm_polygons(col = "cumsumCases", style =  "log10_pretty", title = "Cumulative number of cases")
})




}





# Run the app ----
shinyApp(ui = ui, server = server)
  
  
  






