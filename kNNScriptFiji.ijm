//Working example set
//Specify absolute path to working directory
wd = "C:/Users/...path to working directory.../"

//Input sets: Find nearest neighbours to setA in setB
//results file will have equal # of rows to setA
setA = wd + "TestCoordinates1.csv"
setB =  wd + "TestCoordinates2.csv"

scriptName = wd + "kNNScript.R"

outputName = wd + "macro_test"

//How many nearest neighbours do you want to find?
k=4
print("Starting Rscript")

//Command line script --> note 2>&1 redirects stdout to the log file
//Allows for debugging of command line arguments
//exec("Rscript",scriptName,"test", "2>&1")
exec("Rscript",scriptName,setA,setB,k,outputName,"plot","2>&1")

print("Script ended")
