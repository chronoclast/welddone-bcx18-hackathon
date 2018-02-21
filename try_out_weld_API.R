library(jsonlite)
library(RCurl)

result <- fromJSON("http://100.102.5.8:8000/nws-rest-api/last-weld")
getURL("http://100.102.5.8:8000/nws-rest-api/last-weld") 

# to parse the date
as.POSIXct(result$date, origin="1970-01-01")

# to calculate the resistance
df <- as.data.frame(result$current)
names(df) <- "current"
df$voltage <- result$voltage
df$resistance <- df$voltage/df$current

df$current <- scale(df$current)
df$voltage <- scale(df$voltage)
df$resistance <- scale(df$resistance)

plot(x=row.names(df),y=df$current, type="l",col="limegreen", ylim=c(-2,4))
lines(x=row.names(df),y=df$resistance,col="red")
lines(x=row.names(df),y=df$voltage)

#origin_par <- par()
#par(mfrow=c(3,1))
#plot(x=row.names(df),y=df$current, type="l",col="limegreen")
#plot(x=row.names(df),y=df$resistance,col="red", type ="l")
#plot(x=row.names(df),y=df$voltage, type="l")

# V = I (current) * R

#{ "read-or-write" : "read",                
#  "request" : "spot",              
#  "overview-list" : "no",  
#  "id" : "",    
#  "name" : "Spot_12_231" }      