library(shiny)
library(httr)
library(shinydashboard)
library(jsonlite)

df <- as.data.frame(sample(c(50.5:300),20))
names(df) <- "current"
df$resistance <- sample(c(70.5:150),20)
df$volt <- sample(c(110.5:170.8),20)


ui <- dashboardPage(
  dashboardHeader(disable = TRUE),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(solidHeader = TRUE, status = "danger", title = div(icon("bolt","fa-fw"),"Last Weld"),
        plotOutput("weld")),
      box(solidHeader = TRUE, status = "danger", title = div(icon("image","fa-fw"),"SickScan"),
        uiOutput("pic"))),
    actionButton("refresh","Refresh", icon("refresh"))
  )
)

server <- function(input, output){
  dat <- reactive({
    invalidateLater(1000)
    df <- as.data.frame(sample(c(50.5:300),20))
    names(df) <- "current"
    df$resistance <- sample(c(70.5:150),20)
    df$volt <- sample(c(110.5:170.8),20)
    return(df)
  })
  output$weld <- renderPlot({
    df <- dat()
    plot(x=row.names(df),y=df$current, type="l",col="limegreen", ylim = c(1,350))
    lines(x=row.names(df),y=df$resistance,col="red")
    lines(x=row.names(df),y=df$volt)
  })
  output$pic <- renderUI({
    input$refresh
    isolate({
      num <- sample(c(1,2),1)
      files <- list.files("www/")
      image <- files[num]
      div(img(src=image), style="text-align: center;")
    })  
  })  
}

shinyApp(ui, server)


#### OLD ####
# ui <- fluidPage(
#   fluidRow(
#     box(plotOutput("weld")),
#     box(uiOutput("pic"))),
#   actionButton("refresh","Refresh", icon("refresh"))
# )

# library(shiny)
# library(httr)
# library(jsonlite)
# library(plotly)
# #library(shinydashboard)
# 
# setwd("D:/boschebol_hackathon/boschebol-gehaktbol")
# #df <- data.frame()
# df <- as.data.frame(sample(c(50.5:300),20))
# names(df) <- "current"
# df$resistance <- sample(c(70.5:150),20)
# df$volt <- sample(c(110.5:170.8),20)
# 
# 
# ui <- fluidPage(
#   fluidRow(
#     box(plotOutput("weld")),
#     box(uiOutput("pic"))),
#   plotOutput("sensor"),
#   actionButton("refresh","Refresh", icon("refresh"))
# )
# 
# server <- function(input, output){
#   readWeld <- reactive({
#     invalidateLater(1000)
#     df <- as.data.frame(sample(c(50.5:300),20))
#     names(df) <- "current"
#     df$resistance <- sample(c(70.5:150),20)
#     df$volt <- sample(c(110.5:170.8),20)
#     #df <<- rbind(df,df)
#     return(df)
#   })
#   output$weld <- renderPlot({
#     #df <- readWeld()
#     #print(df)
#     plot(x=row.names(df),y=df$current, type="l",col="limegreen", ylim = c(1,350))
#     lines(x=row.names(df),y=df$resistance,col="red")
#     lines(x=row.names(df),y=df$volt)
#   })
#   output$pic <- renderUI({
#     input$refresh
#     isolate({
#       num <- sample(c(1,2),1)
#       files <- list.files("www/")
#       image <- files[num]
#       tags$img(src=image)
#     })  
#   })  
# }
# 
# shinyApp(ui, server)
