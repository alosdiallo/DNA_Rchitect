# DNA Rchitect

## Welcome to the github repository for DNA Rchitect, a Shiny App for visualizing genomic data. 
Start using the [web version](https://simongray.shinyapps.io/DNARchitect/) of this application, or download the [source code](https://github.com/alosdiallo/HiC_Network_Viz_tool/tree/master/App) and run locally. 

## Table of Contents
[Introduction](#introduction)<br>
[Installation instructions](#installation-instructions)<br>
[Web version](#web-version)<br>
[Header requirements](#header-requirements)<br>
[Tutorial](#tutorial)<br>
[Errors and Troubleshooting](#errors-and-troubleshooting)<br>
...[HiC Error](#hic-error)<br>
[References](#references)<br>

### Introduction
[Shiny Apps](https://shiny.rstudio.com/) are interactive web applications built with R using the `shiny` R package. Shiny apps are built with R wrappers for HTML, CSS, and JS to run R code in a web browser through a dynamic and reactive user interface that is powered by an underlying NodeJS engine. These apps can be locally hosted from an R session or hosted in the cloud through a [ShinyServer](http://www.shinyapps.io/).

### Installation instructions
Instructions for locally installing and running this app through RStudio are provided [here](https://github.com/alosdiallo/HiC_Network_Viz_tool/blob/master/Installation_setup.txt). <br>

### Web version
A [web version](https://simongray.shinyapps.io/DNARchitect/) of the App is available for use in the cloud. Note that the web version has a **hard maximum of 8 GB of RAM** per instance. If you exceed 8 GB of RAM during your analysis, the web version of the app will be killed by the server. If you are analyzing large data files (total uploaded file sizes add to > 4 GB), we recommend installing and running a local version of the app through RStudio, as described in [installation instructions](#installation-instructions)

### Header requirements
All files must have the following standard headers. Missing or misspelled headers will lead to processing errors. Non-required headers will be ignored<br>

| File Format   | Required headers                                                |
| ------------- |:---------------------------------------------------------------:|
| bed           | chrom, start, stop                                              |
| bedpe         | chrom1, start1, end1, chrom2, start2, end2, score, samplenumber |
| bedgraph      | chrom, start, stop, value                                       |

### Tutorial
There is an interactive tutorial accessible through the help button on the app. Access a [PDF version](https://github.com/alosdiallo/HiC_Network_Viz_tool/blob/master/Tutorial.pdf) of the tutorial here.

### Errors and Troubleshooting

1. Incorrect headers: If you upload a file with the wrong headers, a dialog box will appear after pressing the **Process Data** button indicating that the file does not contain the appropriate headers. Adjust your file's headers appropriately and re-upload then re-process the file.
2. HiC plotting error: <br>
`Error: Current genomic window cannot be plotted, probably because an anchor crosses the plot boundary. Adjust genomic window coordinates (zoom in or out) and re-submit` <br>
This error indicates that the current genomic window (as defined by the genomic interval to left and right of gene or by the selected coordinates) contains a HiC anchor on the plot boundary. Adjust your window and click **Submit Parameters** again. Repeat until your window plots properly (ie until your boundary coordinates do not intersect anchors).
3. Cytoscape network graph error <br>
`Error: The genomic window does not contain any nodes` <br>
This error indicates that the selected genomic window does not contain any HiC anchors (ie nodes). Enlarge the genomic window until it contatins HiC anchors. <br>
See the [PDF tutorial](https://github.com/alosdiallo/HiC_Network_Viz_tool/blob/master/Tutorial.pdf) for more information, including examples of each error in the App.

### References
This application utilizes the following packages and libraries:<br>
[IntroJS](https://introjs.com/)<br> 
[Cytoscape.js](http://js.cytoscape.org/)<br>
[`rcytoscapejs`](https://github.com/cytoscape/r-cytoscape.js)<br>
[`shiny`](https://cran.r-project.org/web/packages/shiny/index.html)<br>
[`shinyBS`](https://cran.r-project.org/web/packages/shinyBS/index.html)<br>
[`jsonlite`](https://cran.r-project.org/web/packages/jsonlite/index.html)<br>
[`Sushi`](https://bioconductor.org/packages/release/bioc/html/Sushi.html)<br>
[`DT`](https://cran.r-project.org/web/packages/DT/index.html)<br>
[`RColorBrewer`](https://cran.r-project.org/web/packages/RColorBrewer/index.html)<br>

[MIT Licence](https://opensource.org/licenses/MIT)
