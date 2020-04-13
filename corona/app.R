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
   plotOutput("mainpanelplot"),
#   plotOutput("worldmap"),
   plotOutput("worldmap")
    )
    
    
    )
  
)

# Server logic
#TODO: Server selectize

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
  
  
  
#Create plot  
  
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
#mapData = reactive({ joinCountryData2Map(dateData(), joinCode = "ISO3", nameJoinColumn = "countryterritoryCode")
#                   })



# output$worldmap <- renderPlot({mapParams<- mapCountryData(mapData(),
#                                            mapTitle = "Number of reported cases",
#                                            nameColumnToPlot="cumsumCases",
#                                            catMethod='logFixedWidth',
#                                            addLegend = FALSE)
#                               
#                                do.call(addMapLegend,
#                                         c(mapParams,
#                                          legendLabels = 'limits',
#                                          legendIntervals = 'data',
#                                          legendWidth = 0.5
#                                ))
#                                  
#                                })


 
 
 
 #TODO: dateData: nur DateRep und cumsumCases auswählen, Duplikate entfernen. Dann nochmal leaflet testen
mapData2<- reactive({
   sp::merge(world, dateData(), by.x ="iso_a2", by.y="geoId")
 })


output$worldmap = renderPlot({
   tm_shape(mapData2())+tm_polygons(col = "cumsumCases", style =  "log10_pretty")
})




}






# Run the app ----
shinyApp(ui = ui, server = server)
  
  
  






