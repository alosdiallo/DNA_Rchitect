![DNA Rchitect](https://storage.googleapis.com/gencode_ch_data/logo2.png)  

## Welcome to the github repository for DNA Rchitect, a Shiny App for visualizing genomic data. 
Start using the [web version](http://shiny.immgen.org/DNARchitect/) of this application, or download the [source code](https://github.com/alosdiallo/HiC_Network_Viz_tool/tree/master/App) and run locally. 

## Table of Contents
[Introduction](#introduction)<br>
[Installation instructions](#installation-instructions)<br>
[Web version](#web-version)<br>
[Supported browsers](#supported-browsers)<br>
[Header requirements](#header-requirements)<br>
[Tutorial](#tutorial)<br>
[Errors and Troubleshooting](#errors-and-troubleshooting)<br>
1. [Incorrect headers](#incorrect-headers)<br>
2. [HiC Plotting Error](#hic-plotting-error)<br>
3. [Cytoscape network graph error](#cytoscape-network-graph-error)<br>
4. [Grayed out page](#grayed-out-page)<br>
5. [Maximum upload size exceeded](#maximum-upload-size-exceeded)<br>
6. [Shiny deploy error](#shiny-deploy-error)

[Sample data](#sample-data)<br>
[Adding gene annotation for a new species](#adding-gene-annotation-for-a-new-species)<br>
[References](#references)<br>
[MIT License](#mit-license)<br>

### Introduction
DNA Rchitect is a Shiny App for visualizing genomic data (HiC, mRNA, ChIP, ATAC etc) in bed, bedgraph, and bedpe formats. HiC (bedpe format) data is visualized with both bezier curves and a [cytoscape](http://www.cytoscape.org/) network graph (using an R port of [cytoscapejs](http://js.cytoscape.org/)). [Shiny Apps](https://shiny.rstudio.com/) are interactive web applications built with R using the `shiny` R package. Shiny apps are built with R wrappers for HTML, CSS, and JS to run R code in a web browser through a dynamic and reactive user interface that is powered by an underlying NodeJS engine. These apps can be locally hosted from an R session or hosted in the cloud through a [ShinyServer](http://www.shinyapps.io/).

### Installation instructions 
System requirements and instructions for locally installing and running this app through RStudio are provided [here](https://github.com/alosdiallo/HiC_Network_Viz_tool/blob/master/Installation_setup.txt). Note that an internet connection is still required to run the locally installed app. Detailed installation instructions are as follows:
1. You must have RStudio and R installed on your computer. Instructions for installing R and Rstuio can be found [here](https://github.com/alosdiallo/HiC_Network_Viz_tool/blob/master/R_Rstudio_Installation.md)
2. Download this github repository by clicking on the green **Clone or Download** button on the right side of the main [repository page](https://github.com/alosdiallo/HiC_Network_Viz_tool). The downloaded folder will include the App, a folder with sample data, and a PDF tutorial for using the App. More help on how to clone or download a github repository is provided [here](
https://help.github.com/articles/which-remote-url-should-i-use/).
2. Navigate to the App folder on your computer and open the file:DNARchitect.R in RStudio
3. Click 'Run App'
4. If your data files are >1000 MB, increase the default maximum file size as explained in [Maximum upload size exceeded](#maximum-upload-size-exceeded)


### Web version
A [web version](https://simongray.shinyapps.io/DNARchitect/) of the App is available for use in the cloud. Note that the web version has a **hard maximum of 8 GB of RAM** per instance. If you exceed 8 GB of RAM during your analysis, the web version of the app will be shutdown by the server. If you are analyzing large data files (especially if the sum of your uploaded file sizes exceeds 4 GB), we recommend installing and running a local version of the app through RStudio, as described in [installation instructions](#installation-instructions). The web version of the App will shutdown after 15 minutes of inactivity and all uploaded data and analysis will be deleted. The web version does not store your data for use at a later time -- you must upload your files with each new session of the web version of the App. Running a locally installed version allows you to keep the App open indefinitely and the maximum RAM per instance is limited only by your computer's hardware. The web version permits a maximum file size of 1000 MB.

### Supported browsers
- Chrome
- Firefox
- Safari
- Microsoft Internet Explorer
- Microsoft Edge

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

#### Incorrect headers
If you upload a file with the wrong headers, a dialog box will appear after pressing the **Process Data** button indicating that the file does not contain the appropriate headers. Adjust your file's headers appropriately and re-upload then re-process the file. If you specified the wrong separator or quote type in the upload panel for that file, the data will process incorrectly and the displayed table will appear without appropriate separation between columns. This will lead the App to believe that the headers are wrong (because all header columns will be combined into a single column) and give you the 'incorrect header' warning -- to fix this error correct your separator or quote selections and re-upload then re-process the file.

#### HiC Plotting Error
`Error: Current genomic window cannot be plotted, probably because an anchor crosses the plot boundary. Adjust genomic window coordinates (zoom in or out) and re-submit` <br>
The above error indicates that the current genomic window (as defined by the genomic interval to left and right of gene or by the selected coordinates) contains a HiC anchor on the plot boundary. Adjust your window and click **Submit Parameters** again. Repeat until your window plots properly (ie until your boundary coordinates do not intersect anchors).

#### Cytoscape network graph error
`Error: The genomic window does not contain any nodes` <br>
The above error indicates that the selected genomic window does not contain any HiC anchors (ie nodes). Enlarge the genomic window until it contatins HiC anchors. <br>
See the [PDF tutorial](#tutorial) for more information, including examples of each error in the App.

#### Grayed out page
`Disconnected from server`<br>
`Reload`<br>
If the page 'grays out' with the above error message, the App has disconnected from the server. This may occur because you left the App idle for >15 minutes (at which time the active instance is shut down), your internet connection was disrupted, or you exceeded the **hard maximum of 8 GB of RAM** per instance (which causes the web version of the app to die -- see [Web version](#web-version) for more details). See the Shiny docs for more information on [grey screens](http://docs.rstudio.com/shinyapps.io/Troubleshooting.html#grey-screen).

#### Maximum upload size exceeded
`Maximum upload size exceeded`<br>
The above warning will displayed if you attempt to upload a file exceeding 1000 MB. The [web version](https://simongray.shinyapps.io/DNARchitect/) of the app has a maximum individual file size of 1000 MB. To analyze files larger than 1000 MB, [install](#installation-instructions) and run a local version of the app on your computer. The default maximum file size is 1000 MB on the locally installed app. To increase the maximum file size, edit the following line of code: <br>
`options(shiny.maxRequestSize = 1000*1024^2)`<br>
For example, to increase maximum file size to 2000 MB adjust the code as follows:<br>
`options(shiny.maxRequestSize = 2000*1024^2)`<br>

#### Shiny Deploy Error
`Unable to determine package source for Bioconductor package BiocGenerics: Repository must be specified` <br>
The above error may occur while trying to deploy the App to ShinyApps.io or a private ShinyServer. The error seems to occur because the Bioconductor repository is not locally configured. See this [discussion](https://groups.google.com/forum/#!topic/shinyapps-users/zaUay_lM-lY) and check the repository configurations with `getOption("repos")`. Run the following code in your R console to configure the Bioconductor respository: <br>
`options(repos = BiocInstaller::biocinstallRepos())` <br>
If this does not resolve the issue, close the App file and try the following (or some combination):
1. Delete the **rsconnect** folder from the source directory for the App
2. Go to Session... and click **Clear Workspace...**
3. Go to Session... and click **Restart R...**
4. Open the App file and set working directory to App source file location (you may need to also **Run App**)
5. Run in the R console: `options(repos = BiocInstaller::biocinstallRepos())`
6. Try to deploy/publish the App

### Sample data
Sample bedpe, bed, and bedgraph data sets for testing with this App are available [here](https://github.com/alosdiallo/HiC_Network_Viz_tool/tree/master/sample_data). You can download this entire github repository (including the **sample_data** folder) by clicking on the green **Clone or Download** button at the top of this page.

### Adding gene annotation for a new species
Use the [speciesTool](https://github.com/alosdiallo/HiC_Network_Viz_tool/tree/master/speciesTool) to generate the required files for adding gene annotation for a new species to the DNARchitect app. The files for each species must be stored using the following convention at the google storage bucket: <br>
`https://storage.googleapis.com/gencode_ch_data/speciesName/fileName`<br>
For example, for the Gencode.chr1.txt gene annotation file for the mouse chr1, the file would be stored at: <br>
`https://storage.googleapis.com/gencode_ch_data/mouse/Gencode.chr1.txt`<br>
There are two types of files that must be included in the new species storage.googleapis.com bucket: <br>
1. The gene annotation files for each chromosome: <br>
Example: `https://storage.googleapis.com/gencode_ch_data/mouse/Gencode.chr1.txt`<br>
2. The searchNames file for the species: <br>
Example: `https://storage.googleapis.com/gencode_ch_data/mouse/mouse_searchNames.txt`<br>
The searchNames file is used by the App to generate options when typing a gene name in the plotting panel for use in the searchByGene function. <br>

#### Changes required to code when adding new species
The code must be changed in 3 places to accomodate a new species.<br>
1. `geneNames`: Each new species requires its own column in the `geneNames` object. Create a new `geneNames$yourNewSpecies` and update the URL so that the pulled file comes from the correct directory (ie: `https://storage.googleapis.com/gencode_ch_data/yourNewSpecies/yourNewSpecies_searchNames.txt`, where `yourNewSpecies` must be updated). Note that the `yourNewSpecies` must be the same name used in `input$genome` <br>
2. `output$chromNumberUI`: Each new species requires its own case in the switch statement to render UI for selecting the chromosome to visualize. Follow the existing code and add your new species. <br>
3. `output$searchNamesList`: Each new species requires its own case in the switch statement to render UI for visualizing by gene. Follow the exisintg code and add your new species. <br>

#### The follow species are currently supported by the App
1. mouse <br>
2. human <br>
3. drosophila_melanogaster <br>

### References
This application utilizes the following packages and libraries:<br>
[`IntroJS`](https://introjs.com/)<br> 
[`Cytoscape.js`](http://js.cytoscape.org/)<br>
[`rcytoscapejs`](https://github.com/cytoscape/r-cytoscape.js)<br>
[`shiny`](https://cran.r-project.org/web/packages/shiny/index.html)<br>
[`jsonlite`](https://cran.r-project.org/web/packages/jsonlite/index.html)<br>
[`Sushi`](https://bioconductor.org/packages/release/bioc/html/Sushi.html)<br>
[`DT`](https://cran.r-project.org/web/packages/DT/index.html)<br>
[`RColorBrewer`](https://cran.r-project.org/web/packages/RColorBrewer/index.html)<br>

Authors
--------------------
	Simon Matthew Gray - Division of Immunology, Harvard Medical School
	Ricardo Ramirez - Department of Microbiology & Immunobiology, Harvard Medical School
	Karni Bedirian - Division of Immunology, Harvard Medical School
	Alos Diallo - Division of Immunology, Harvard Medical School
	
Copyright © 2018 the President and Fellows of Harvard College.
![Blavatnikimmunology](https://storage.googleapis.com/gencode_ch_data/Blavatnikimmunology.jpg)  
![Immgen](https://storage.googleapis.com/gencode_ch_data/immgen.png)  

### [MIT License](https://github.com/alosdiallo/HiC_Network_Viz_tool/blob/master/Licence.txt)
