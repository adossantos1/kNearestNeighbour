# kNearestNeighbour
K nearest neigbour search script combined with Fiji macro

<h2>Requirements</h2>
  
* Rscript (added to PATH variable)
* [RANN package](https://rdrr.io/cran/RANN/man/nn2.html)

<h2>To Run</h2>
<h3>Command Line</h3>

Test command
```
Rscript kNNScript.R test
```

With input
```
Rscript kNNScript.R inputA.csv inputB.csv [#k nearest neighbours to find] ouputName plot
```

<h3>Run from Fiji Macro</h3>

* NOTE: Absolute paths should be provided to the script or it will read from the Fiji app directory

* a. Specify the absolute path to the working directory
```
//Specify absolute path to working directory
wd = "C:/Users/...path to working directory.../"
```

* b. Specify input files, number of nearest neighbours to calculate (k) and output name (should contain no file extension)

<h3>Inputs</h3>

* Two csv files with X and Y coordinates with no headers

<h3>Outputs</h3>

* One csv file with the query coordinate set and coordinate sets for k nearest neighbours
* [Optional] Plot with query set and nearest neighbour for each
