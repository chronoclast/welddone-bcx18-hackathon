library(RCurl)
url <- "ftp://192.168.1.2"
userpwd <- "weld:done"
filenames <- getURL(url, userpwd = userpwd,
                    ftp.use.epsv = FALSE,dirlistonly = TRUE) 

destnames <- filenames <-  strsplit(filenames, "\r*\n")[[1]] # destfiles = origin file names
destnames <- filenames <- filenames[grepl("\\.png",filenames)]
filenames <- paste0(url,"/",filenames)
con <-  getCurlHandle(ftp.use.epsv = FALSE, userpwd="weld:done")
mapply(function(x,y) writeBin(getBinaryURL(x, curl = con, dirlistonly = FALSE), 
                              y), x = filenames, y = paste("D:/boschebol_hackathon/boschebol-gehaktbol/www/",destnames, sep = "")) #writing all zipped files in one directory

