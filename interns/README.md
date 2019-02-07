# Resources 

## Table of Contents
[Getting started](#getting-started)<br>
[DNARchitect Development](#dnarchitect-development)<br>
[Help](#help)<br>

## Getting started
### Getting started with R, ShinyApps, and Genomic data visualization

If you've never used R, read about it then download R and RStudio. You'll need to understand CRAN and Bioconductor too: <br>
https://en.wikipedia.org/wiki/R_(programming_language) <br>
https://en.wikipedia.org/wiki/R_(programming_language)#CRAN <br>
https://en.wikipedia.org/wiki/Bioconductor <br>

R and Rstudio can be downloaded as per these instructions: <br>
https://github.com/alosdiallo/HiC_Network_Viz_tool/blob/master/R_Rstudio_Installation.md <br>
https://biodatascience.github.io/compbio/github.html <br>

Work through these shiny tutorials to understand how Shiny is used to create interactive R sessions in a web browser: <br>
https://shiny.rstudio.com/tutorial/ <br>

The following series of articles gives a comprehensive explanation of most aspects of Shiny. This should be your first stop for any questions, troubleshooting, debugging etc: <br>
https://shiny.rstudio.com/articles/

Read the Introduction and Getting Started sections of the shinyapps.io documentation to understand how to deploy shiny apps to the cloud: <br>
http://docs.rstudio.com/shinyapps.io/ <br>

To understand the Network plots created with RCytoscape read about: <br>
https://en.wikipedia.org/wiki/Network_theory <br>
http://js.cytoscape.org/#introduction <br>
https://github.com/cytoscape/r-cytoscape.js <br>
This is a demo network using cytoscapejs: http://js.cytoscape.org/demos/visual-style/ <br>

If you've never worked with genomic data, read about: <br>
https://en.wikipedia.org/wiki/RNA-Seq <br>
https://en.wikipedia.org/wiki/ChIP-sequencing <br>
https://en.wikipedia.org/wiki/ATAC-seq <br>
https://en.wikipedia.org/wiki/Chromosome_conformation_capture <br>

To understand the bed, bedgraph, and bedpe plots created with Sushi read about: <br>
https://bioconductor.org/packages/devel/bioc/vignettes/Sushi/inst/doc/Sushi.pdf <br>

To download data from our cloud instance: <br> 
First download the sdk https://cloud.google.com/sdk/docs/ <br>
Then run: gcloud init 
Finally run: "gsutil -m cp -R gs://gencode_ch_data ."


## DNARchitect Development

Comments starting with `# ###-----------` demarcate areas of code that would benefit from improvement <br>

### Development work:
1. Include option to plot multiple bedGraph (or bed) datasets using a single plotBedgraph (or plotBed) call -- this will adding UI elements to a) activate multiple datasets in 1 bedgraph plot, b) specify which datasets.
2. Expand number of datasets that may be uploaded and analyzed to a user defined number -- this will require generalizing the code
3. Figure out how to get introJS to transition backwards with tab changes (currently the App uses JS to change Tabs as the tutorial progresses in the forward direction, but it cannot change tabs when the tutorial progresses in the reverse direction.
4. Generalize code to make adding new species easier
5. Improve functions so that they can be unit tested. This will involve defining in the comments the required inputs and expected outputs, and creating a success or failure output code for each function.
6. Make a generalized data_read function that overloads the dataFileType specific functions depending on the type of data (This would create a single function from reqRead and the *dataRead [ie HiCdataRead, etc] functions)
7. Improve the checkHeader function
8. Consider adding mirrors for the files pulled from storage.googleapis.com

## Help
The most comprehensive and detailed explanations of Shiny capabilities, troubleshooting, debugging, and features can be found in this collection of articles: <br>
https://shiny.rstudio.com/articles/
