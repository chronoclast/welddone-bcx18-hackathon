library(jsonlite)
library(RCurl)

result <- fromJSON("http://100.102.5.8:8000/nws-rest-api/last-weld")
getURL("http://100.102.5.8:8000/nws-rest-api/last-weld") 


#{ "read-or-write" : "read",                
#  "request" : "spot",              
#  "overview-list" : "no",  
#  "id" : "",    
#  "name" : "Spot_12_231" }      