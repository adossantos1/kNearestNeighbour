#!/usr/bin/Rscript

#install.packages("RANN")
library(RANN)
rm(list  = ls())

##Command line example: Rscript name_of_script.R input_A.csv input_B.csv k-nearest-neighbours# output_name plot
##NOTE: input csvs must be have the same number of columns (X and Y) and should have no header
##Order of input sets matter: input_A.csv will be queried against input_B.csv
##ie. What is the closest  neighbour in (B) of (A)

startTime <- Sys.time()
test = FALSE
args = commandArgs(trailingOnly=TRUE)


#Run example test set, subsequent arguments will be ignored
if(identical(tolower(args[1]), "test")) {
  test = TRUE
  print("Running test sample")
}

# Test if there is at least one argument: if not, return an error
if (length(args) < 2 && !test) {
  print("Command line example: Rscript kNNScript.R C:/path_to_A/input_A.csv C:/path_to_B/input_B.csv k-nearest-neighbours# C:/path_to_output/output_name plot")
  stop("At least one argument must be supplied (input file).n", call.=FALSE) 
}

#Set input csvs
#Ensure inputs are valid
if(test) {
  #Create some test data
  setA <- cbind(v1=sample(100000, 1000, replace = TRUE),v2=sample(100000, 1000, replace = TRUE))
  setB <- cbind(V1=sample(100000, 1000, replace = TRUE),V2=sample(100000, 1000, replace = TRUE))
  outputName = "NNOutput"
  k = 1
  makePlot = TRUE
} else {
  
  tryCatch({
    setA <-read.csv(args[1], header = FALSE, fileEncoding="UTF-8-BOM")
    setB <- read.csv(args[2], header = FALSE, fileEncoding="UTF-8-BOM")
    
  }, error=function(cond) {
    message("Input files invalid or can't be read")
    message("Two inputs must be provided as csv files.")
    message("Each csv should have 2 columns corresponding to the x and y coordinates")
    message(cond)
  }, warning=function(cond){message(cond)},
  finally={})
  
  if(is.na(args[3]) || length(args) < 3) {
    k <- 1
  } else {
    print(args[3])
    k <- args[3]
    k <- min(as.integer(k), nrow(setB)) 
    if(is.na(k)) { k <- 1}
  }
  
  outputName <-tryCatch({
    if(length(args) < 4) {
      outputName <- "NNOutput"
    } else {
      outputName <- args[4]
    }
    
  }, error=function(cond){return("NNOutput")}, warning=function(cond) {
    message(cond)
    message("Unable to read desired output name. Using default:NNOutput")
    return("NNOutput")
  }, finally={}
  )
  
  if(length(args) == 5) {
    input <- args[5]
    if(identical(tolower(input), "plot")) {
      makePlot <- TRUE
    } else {
      makePlot <- FALSE
      print("No plot will be saved.")
    }
  } else {
    makePlot <- FALSE
    print("No plot will be saved.")
  }

}

logFile <- file(paste0(outputName, ".txt"), "w")
writeLines(date(), logFile)
writeLines(paste0("SetA: ", args[1], "\nSetB: ", args[2]), logFile)

### END OF ARGUMENT PARSING

startTime <- Sys.time()
writeLines(paste0("k=", k, "\nFiles saved to: ", outputName,".ext\n\n"), logFile)

#Results are 2 lists: 
#a. the k nearest neighbour indices in setB
#b. the k nearest euclidean distances from points in set A

results = nn2(setB, query = setA, min(k, nrow(setB)) , treetype = c("kd"), searchtype = c("priority"))
print("Approximate nearest neighbout calculations complete.")
runningTime = Sys.time()
log <- paste0("Subprocess completed in ", runningTime-startTime)
writeLines(log, logFile)
print(log)
  
#Transform data - bind setA with k nearest neighbour coordinates
#a. for each of k points create new columns Xi, Yi

output <- setA
colnames(output)[1] <- "X"
colnames(output)[2] <- "Y"

logText <- "Formatting results into useable format..."
writeLines(logText, logFile)
print(logText)

for (i in  1:k) {

  # Get indices if iTH nearest neigbours and add onto output
  output <- cbind(output, index = results[["nn.idx"]][,i])
  
  # Match coordinates from original nearest neighbour dataset (setB) to output set using 'index' as joining column
  output <- merge(output, setB, by.x = 'index', by.y=0, all.x = TRUE)
  
  # Remove index column from output. Allows for next nearest neighbour index to be added.
  output <- subset(output, select = -c(index))
  
  
  #Rename iTH nearest neigbour coordinates
  xName = paste0("X", i)
  yName = paste0("Y",i)
  colnames(output)[1+i*2] <- xName
  colnames(output)[2+i*2] <- yName
  
}
logText = paste0("Subprocess completed in ", Sys.time() - runningTime)
print("Processing complete.")
writeLines(logText, logFile)
print(logText)
runningTime = Sys.time()

#d. write that baby to a csv
write.csv(output, paste0(outputName,".csv"))
logText <- paste0("Output saved as: ", outputName, ".csv")
print(logText)
writeLines(logText, logFile)
close(logFile)

if(makePlot) {
  svg(filename=paste0(outputName, ".svg"), 
      width=10, 
      height=10, 
      pointsize=12)

  plot(output$X, output$Y, col = "green", type = "p", ylab = "Y", xlab = "X")
  points(setB, col="red", type="p")
  for(i in 0:nrow(output)) {
    lines(rbind(output[i,"X"], output[i, "X1"]), rbind(output[i,"Y"], output[i,"Y1"]))
  }
  dev.off()
}

print(getwd())

#All done. Clean-up
rm(list = ls())