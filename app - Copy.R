library(shiny)
library(httr)
library(shinydashboard)
library(jsonlite)

#df <- as.data.frame(sample(c(50.5:300),20))
#names(df) <- "current"
#df$resistance <- sample(c(70.5:150),20)
#df$volt <- sample(c(110.5:170.8),20)


result <- fromJSON("http://100.102.5.8:8000/nws-rest-api/last-weld")
temp <- as.data.frame(result$current)
names(temp) <- "current"
temp$voltage <- result$voltage
temp$resistance <- temp$voltage/temp$current

#temp$current <- scale(temp$current)
#temp$voltage <- scale(temp$voltage)
#temp$resistance <- scale(temp$resistance)
df <- temp

ip_addr = 'http://192.168.1.1/port0.jsn'
beat_df <- NULL

ui <- dashboardPage(
  dashboardHeader(disable = TRUE),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(solidHeader = TRUE, status = "danger", title = div(icon("bolt","fa-fw"),"Last Weld"),
        uiOutput("infoboxes"),
        plotOutput("weld", height = "800px")),
      div(box(solidHeader = TRUE, status = "danger", title = div(icon("image","fa-fw"),"SickScan"),
        uiOutput("pic"))),
          box(solidHeader = TRUE, status = "danger", title = div(icon("heartbeat","fa-fw"),"Part passing through..."),
        plotOutput("heartbeat")
      )
    )
  )
)

server <- function(input, output){
  output$heartbeat <- renderPlot({ #heartbeat plot ####
    df <- iolink()
    plot(x=df$time, y=df$value, type="l",col="limegreen", ylim=c(0,1), lwd=2)
  })
  iolink <- reactive({ #iolink reactive ####
    invalidateLater(250)
    balluf_result <- fromJSON(ip_addr)
    dist <- strtoi(tolower(gsub("\\ ","",substr(balluf_result[[2]]$processInputs,1,5))),16)/10
    print(dist)
    r <- as.data.frame(Sys.time())
    names(r) <- "time"
    r$value <- ifelse(dist < 6000,1,0)
    if(r$value == 1){
      print("Value is 1!")
    }
    beat_df <<- rbind(beat_df, r)
    if (nrow(beat_df) > 30){
      beat_df <<- beat_df[-1,]
    }
    return(beat_df)
  })
  dat <- reactive({ #api call reactive ####
    invalidateLater(5000)
    result <- fromJSON("http://100.102.5.8:8000/nws-rest-api/last-weld")
    temp <- as.data.frame(result$current)
    names(temp) <- "current"
    temp$voltage <- result$voltage
    temp$resistance <- temp$voltage/temp$current
    temp$spatter <- result$spatterTime
    temp$error <- result$errorCode
    #temp$current <- scale(temp$current)
    #temp$voltage <- scale(temp$voltage)
    #temp$resistance <- scale(temp$resistance)
    df <<- temp
    return(df)
  })
  
  output$infoboxes <- renderUI({ #infoboxes ####
    df <- dat()
    fluidRow(
      infoBox(title = "Splatter",icon = icon("tint"), color = "lime",
            value = ifelse(df$spatter[1]!=0,"Yes","No")),
      infoBox(title = "Error",icon = icon("exclamation-circle"), color = "orange",
              value = ifelse(df$error[1]!=0,"Yes","No")),
      infoBox(title = "Time",icon = icon("recycle"), color = "purple",
              value = "1 Sec")
    )
  })
  output$weld <- renderPlot({ #api call plot ####
    df <- dat()
    #plot(x=row.names(df),y=df$current, type="l",col="limegreen", ylim = c(-2,4))
    #lines(x=row.names(df),y=df$resistance,col="red")
    #lines(x=row.names(df),y=df$volt)
    par(mfrow=c(3,1))
    plot(x=row.names(df),y=df$current, type="l",col="limegreen")
    plot(x=row.names(df),y=df$resistance,col="red", type ="l")
    plot(x=row.names(df),y=df$voltage, type="l")
  })
  output$pic <- renderUI({ #SICK pic ####
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
