library(shiny)
library(httr)
library(shinydashboard)
library(jsonlite)
library(RCurl)

# Make reactive flags
values <- reactiveValues(flag = FALSE, sick_flag = FALSE, 
                         prev_time = NULL, cur_time = Sys.time(),
                         process_time = NULL, image_ok=NULL)

result <- fromJSON("http://100.102.5.8:8000/nws-rest-api/last-weld")
temp <- as.data.frame(result$current)
names(temp) <- "current"
temp$voltage <- result$voltage
temp$resistance <- temp$voltage/temp$current
df <- temp

ip_addr = 'http://192.168.1.1/port0.jsn'
ftp_url = "ftp://192.168.1.2"
beat_df <- NULL

ui <- dashboardPage( # UI ####
  dashboardHeader(disable = TRUE),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(solidHeader = TRUE, status = "danger", title = div(icon("bolt","fa-fw"),"Last Weld"),
        uiOutput("infoboxes"),
        plotOutput("weld", height = "700px")),
      div(box(solidHeader = TRUE, status = "danger", title = div(icon("image","fa-fw"),"SickScan"),
        uiOutput("pic"))),
          box(solidHeader = TRUE, status = "danger", title = div(icon("heartbeat","fa-fw"),"Part passing through..."),
        plotOutput("heartbeat")
      )
    )
  )
)

server <- function(input, output, session){
  output$heartbeat <- renderPlot({ #heartbeat plot ####
    df <- iolink()
    plot(x=df$time, y=df$value, type="l",col="limegreen", ylim=c(0,1), lwd=2)
  })
  iolink <- reactive({ #iolink reactive ####
    invalidateLater(250)
    balluf_result <- fromJSON(ip_addr)
    dist <- strtoi(tolower(gsub("\\ ","",substr(balluf_result[[2]]$processInputs,1,5))),16)/10
    r <- as.data.frame(Sys.time())
    names(r) <- "time"
    r$value <- ifelse(dist < 6000,1,0)
    if(r$value == 1){
      values$prev_time <-  values$cur_time
      values$flag <- TRUE
      values$sick_flag <- TRUE
      values$cur_time <- Sys.time()
      values$process_time <- paste0(round(values$cur_time - values$prev_time,2),"sec")
    }
    beat_df <<- rbind(beat_df, r)
    if (nrow(beat_df) > 30){
      beat_df <<- beat_df[-1,]
    }
    return(beat_df)
  })
  apiCall <- reactive({ #api call reactive ####
      result <- fromJSON("http://100.102.5.8:8000/nws-rest-api/last-weld")
      temp <- as.data.frame(result$current)
      names(temp) <- "current"
      temp$voltage <- result$voltage
      temp$resistance <- temp$voltage/temp$current
      temp$spatter <- result$spatterTime
      temp$error <- result$errorCode
      df <<- temp
      return(df)
  })
  output$infoboxes <- renderUI({ #infoboxes ####
    if(values$flag==TRUE){
      df <- apiCall()
      values$flag <- FALSE
    }
    fluidRow(
      infoBox(title = "Splatter",icon = icon("tint"), color = "lime",
            value = ifelse(df$spatter[1]!=0,"Yes","No")),
      infoBox(title = "Error",icon = icon("exclamation-circle"), color = "orange",
              value = ifelse(df$error[1]!=0,"Yes","No")),
      infoBox(title = "Time",icon = icon("recycle"), color = "purple",
              value = values$process_time)
    )
  })
  output$weld <- renderPlot({ ## OUTPUT WELD #####
    if(values$flag==TRUE){
      df <- apiCall()
      values$flag <- FALSE
    }
    par(mfrow=c(3,1))
    plot(x=row.names(df),y=df$current, type="l",col="limegreen", main="Current", ylab="Amps", xlab="")
    plot(x=row.names(df),y=df$resistance,col="red", type ="l", main = "Resistance", ylab="Ohms", xlab="")
    plot(x=row.names(df),y=df$voltage, type="l", main="Voltage", ylab="Volt", xlab="")
  })
  sickImage <- reactive({
    invalidateLater(100)
    print("executing...")
    userpwd <- "weld:done"
    filenames <- getURL(ftp_url, userpwd = userpwd,
                        ftp.use.epsv = FALSE,dirlistonly = TRUE) 
    
    destnames <- filenames <-  strsplit(filenames, "\r*\n")[[1]] # destfiles = origin file names
    #destnames <- filenames <- filenames[grepl("\\.png",filenames)]
    filenames <- paste0(ftp_url,"/",filenames)
    con <-  getCurlHandle(ftp.use.epsv = FALSE, userpwd="weld:done")
    mapply(function(x,y) writeBin(getBinaryURL(x, curl = con, dirlistonly = FALSE), 
                                  y), x = filenames, y = paste("D:/boschebol_hackathon/boschebol-gehaktbol/www/",destnames, sep = "")) #writing all zipped files in one directory
    print("Image retrieved!")
    return("image.png")
  })
  output$pic <- renderUI({ #SICK pic ####
    print(paste0("SICK: ",values$sick_flag))
    if(values$sick_flag == TRUE){
      file <- sickImage()
      values$sick_flag <- FALSE
      area <- readLines("www/area.txt")
      if (area == "YES"){
        values$image_ok <- TRUE
      } else {
        values$image_ok <- FALSE
      }
      if(values$image_ok==TRUE){
        feedback = "thumbs_up.png"
      }
      if(values$image_ok==FALSE){
        feedback = "thumbs_down.png"
      }
      print(feedback)
      div(
        fluidRow(
          img(src=feedback, width = 250, height = 250, border=1),
          img(src=file, width = 250, height = 250)),
        style="text-align:center;")
    } else {
      if(!is.null(values$image_ok)){
        if(values$image_ok==TRUE){
          feedback = "thumbs_up.png"
        }
        if(values$image_ok==FALSE){
          feedback = "thumbs_down.png"
        }
        div(
          fluidRow(
            img(src=feedback, width = 250, height = 250),
            img(src="image.png", width = 250, height = 250)),
          style="text-align:center;")
      } else {
        div(
          fluidRow(
            img(src="image.png", width = 250, height = 250),
          style="text-align:center;")
          )
        }  
      }
  })  
}

shinyApp(ui, server)


#### OLD ####

#div(img(src="image.png", width = 350, height = 350), style="text-align:center;")
# if(values$image_ok==TRUE){
#   feedback = "thumbs_up.png"
# } else if(values$image_ok==FALSE){
#   feedback = "thumbs_down.png"
# } else {
#   feedback = NULL
# }
# if(!is.null(feedback)){
#   div(
#     fluidRow(
#       img(src="image.png", width = 250, height = 250),
#       img(src=feedback, width = 250, height = 250)),
#     style="text-align:center;")
# } else {
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

# output$weld <- renderPlot({ #api call plot ####
#   plotReactive()
# })
# plotReactive <- reactive({
#   if(values$flag==TRUE){
#     df <- apiCall()
#     values$flag <- FALSE
#   }
#   par(mfrow=c(3,1))
#   plot(x=row.names(df),y=df$current, type="l",col="limegreen")
#   plot(x=row.names(df),y=df$resistance,col="red", type ="l")
#   plot(x=row.names(df),y=df$voltage, type="l")
# })
