library(shiny)
library(jsonlite)

# PLAN OF ATTACK
# 1) read in the balluf values convert hex to integer; show heartbeat plot
# 2) if Balluf sensor gives 1:
# trigger API call
# while (TRUE){
#   result <- fromJSON(ip_addr)
#   dist <- strtoi(tolower(gsub("\\ ","",substr(result$ProcessInputs[[1]][[1]],1,5))),16)/10
#   print(dist)
#   Sys.sleep(0.2)
# }

ip_addr = 'http://192.168.1.1/port0.jsn'

df <- NULL
api_df <- NULL
#flag <- FALSE


ui <- fluidPage(
  plotOutput("heartbeat"),
  plotOutput("weld")
)
  
server <- function(input, output){
  iolink <- reactive({
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
    df <<- rbind(df, r)
    if (nrow(df) > 30){
      df <<- df[-1,]
    }
    return(df)
  })
  apiCall <- reactive({
    invalidateLater(500)
    result <- fromJSON("http://100.102.5.8:8000/nws-rest-api/last-weld")
    temp <- as.data.frame(result$current)
    names(temp) <- "current"
    temp$voltage <- result$voltage
    temp$resistance <- temp$voltage/temp$current

    temp$current <- scale(temp$current)
    temp$voltage <- scale(temp$voltage)
    temp$resistance <- scale(temp$resistance)
    api_df <<- temp
    print(head(api_df))
  })
  output$heartbeat <- renderPlot({
    df <- iolink()
    plot(x=df$time, y=df$value, type="l",col="limegreen", ylim=c(0,1))
  })
  output$weld <- renderPlot({
    df <- iolink()
    #print(head(df))
    if(df[nrow(df),"value"]==1){
      api_df <- apiCall()
      print("I AM HERE")
      plot(x=row.names(api_df),y=api_df$current, type="l",col="limegreen", ylim=c(-2,4))
      lines(x=row.names(api_df),y=api_df$resistance,col="red")
      lines(x=row.names(api_df),y=api_df$voltage)
    } else {
      if (!is.null(api_df)){
        plot(x=row.names(api_df),y=api_df$current, type="l",col="limegreen", ylim=c(-2,4))
        lines(x=row.names(api_df),y=api_df$resistance,col="red")
        lines(x=row.names(api_df),y=api_df$voltage)
      }
    }
  })
}

shinyApp(ui,server)
  
