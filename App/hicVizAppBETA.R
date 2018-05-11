# DNARchitect
# See our github for documentation: https://github.com/alosdiallo/HiC_Network_Viz_tool


# Code structure:
# #****************************      --> this comment line separates
# major section of the code

# ###-----------      --> this comment line indicates a section requiring
# futher improvement by the developer



#****************************
# The following code checks for and installs (if missing) required packages from
# CRAN, bioconductor, or github. If deploying app to ShinyApps.io, this section
# can be commented out.

# #Packages from CRAN
# requiredPackages = c('shiny','jsonlite','DT','RColorBrewer','devtools')
# for(p in requiredPackages){
#   if(!require(p,character.only = TRUE)) install.packages(p)
#   library(p,character.only = TRUE)
# }
# 
# # Packages from bioconductor
# source("https://bioconductor.org/biocLite.R")
# biocLite() # Install bioconductor core packages
# if (!require("Sushi")) biocLite("Sushi")
# 
# # Packages from github
# library("devtools");
# if (!require("rcytoscapejs")) devtools::install_github("cytoscape/r-cytoscape.js")

#****************************
# The following code loads the packages required for the App.
# Package purpose and (source) are specified.

library(shiny) # Load shiny for shiny app functionality (CRAN)
library(jsonlite) # Load jsonlite for JSON communication in IntroJS (CRAN)
library(rcytoscapejs) # Load rcytoscapejs to generate HiC network (Github)
library(Sushi) #Load sushi for plot functions (BioconductoR)
library(DT) #Load DataTables for data-table functions (CRAN)
library(RColorBrewer) # Load RColorBrewer for color palettes (CRAN)


#****************************
# The following code sets initialization parameters and creates global 
# objects for the app

# Create help data frame with steps for IntroJS introduction/tutorial
steps <- read.csv(file="www/help.csv",header=TRUE,sep=",",quote='"')

# Set maximum file upload size to 1000 mb
options(shiny.maxRequestSize = 1000*1024^2)

# Create dataTypes object to define choices for fileTypes selectizeInput
dataTypes <- c("HiC","ATAC","ChIP","mRNA")

# Download geneNames file for search function
geneNames <- NULL
geneNames$cat <- read.delim("https://storage.googleapis.com/gencode_ch_data/searchNames.txt",header=FALSE,stringsAsFactors = FALSE, sep="\t")

#****************************
# The following code creates FUNCTIONS used in the App.

# FUNCTION: Define function to read uploaded file to a data object that is returned.
# The function requires the file to exist (have been uploaded) to proceed.
# This function is called by the *dataRead (eg HiCdataRead) functions specific to a 
# dataFileType.
reqRead <- function(input, dataFileType){
  
  #Wait until input$HiCFile exists before proceeding...
  req(eval(parse(text = (paste0("input$", dataFileType, "File")))))
  
  data <- read.delim(
    eval(parse(text = (paste0("input$", dataFileType, "File", "$datapath")))),
    header = eval(parse(text = (paste0("input$", dataFileType, "Header")))),
    sep = eval(parse(text = (paste0("input$", dataFileType, "Sep")))),
    quote = eval(parse(text = (paste0("input$", dataFileType, "Quote")))))
  
  return(data)
}

###-----------
# The following section of *dataRead functions (HiCdataRead, ATACdataRead,
# ChIPdataRead, mRNAdataRead) should be generalized to a single function
# in future development.

# FUNCTION: Define function to handle HiC data reading. Note dataFileType
# must be specified because the reqRead function is general and requires
# specification of dataFileType
HiCdataRead <- function(input){
  if("HiC" %in% input$fileTypes){
    dataFileType <- "HiC"
    #Read HiC data
    HiCdata <- reqRead(input, dataFileType)
    return(HiCdata)
  } else {
    #Make HiCdata null
    HiCdata <- NULL
    return(HiCdata)
  }
}

# FUNCTION: Define function to handle ATAC data reading. Note dataFileType
# must be specified because the reqRead function is general and requires
# specification of dataFileType
ATACdataRead <- function(input){
  if("ATAC" %in% input$fileTypes){
    dataFileType <- "ATAC"
    #Read ATAC data
    ATACdata <- reqRead(input, dataFileType)
    return(ATACdata)
  } else {
    #Make ATACdata null
    ATACdata <- NULL
    return(ATACdata)
  }
}

# FUNCTION: Define function to handle ChIP data reading. Note dataFileType
# must be specified because the reqRead function is general and requires
# specification of dataFileType
ChIPdataRead <- function(input){
  if("ChIP" %in% input$fileTypes){
    dataFileType <- "ChIP"
    #Read ChIP data
    ChIPdata <- reqRead(input, dataFileType)
    return(ChIPdata)
  } else {
    #Make ChIPdata null
    ChIPdata <- NULL
    return(ChIPdata)
  }
}

# FUNCTION: Define function to handle mRNA data reading. Note dataFileType
# must be specified because the reqRead function is general and requires
# specification of dataFileType
mRNAdataRead <- function(input){
  if("mRNA" %in% input$fileTypes){
    dataFileType <- "mRNA"
    #Read mRNA data
    mRNAdata <- reqRead(input, dataFileType)
    return(mRNAdata)
  } else {
    #Make mRNAdata null
    mRNAdata <- NULL
    return(mRNAdata)
  }
}

# FUNCTION: Define function to display head or tail of uploaded file
displayUploadedFile <- function(data, input, dataFileType){
  # input$HiCFile will be NULL initially. After the user selects and
  # uploads a file, head of that data file by default, or tail if
  # selected, will be shown
  
  # Wait until input$HiCFile exists before proceeding...
  req(eval(parse(text = (paste0("input$", dataFileType, "File")))))
  
  if(eval(parse(text = (paste0("input$", dataFileType, "Disp")))) == "head") {
    return(head(data))
  }
  else {
    return(tail(data))
  }
}

###-----------
# The following checkHeader function should be improved using case-switch
# to simplify the repeating if-else statement structure

# FUNCTION: Define function to check if uploaded file contains required column headers
# If the column headers are wrong, display a warning using the showModal function
checkHeader <- function(data, dataFileType, input){

  # Possible dataFileType: "HiC","ATAC","ChIP","mRNA"
  # Possible formats: "Bedpe","Bed","Bedgraph"
  
  # Header requirements
  bedpeHeader <- c("chrom1","start1","end1","chrom2","start2","end2","score","samplenumber")
  bedHeader <- c("chrom","start","stop")
  bedgraphHeader <- c("chrom","start","stop","value")
  
  
  if(dataFileType=="HiC"){
    
    if(!all(bedpeHeader %in% colnames(data))){
      showModal(modalDialog(
        title = "Bedpe Input File Header Incorrect",
        tags$p(HTML("The uploaded Bedpe file does not have the correct header or the wrong separator was chosen when uploading. The required header contains: <b>'chrom1','start1','end1','chrom2','start2','end2','score','samplenumber'</b>. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
        easyClose = TRUE
      ))
    }
    
  } else if(dataFileType=="ATAC"){
    
    if(input$atacFormat == "Bed"){
      if(!all(bedHeader %in% colnames(data)) | "value" %in% colnames(data)){
        showModal(modalDialog(
          title = "Bed Input File Header Incorrect",
          tags$p(HTML("The uploaded Bed file does not have the correct header or the wrong separator was chosen when uploading. The required header contains: <b>'chrom','start','stop'</b>. If your file contains 'value', the data will plot as Bed format ignoring the 'value' data. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
        
      }
    } else if (input$atacFormat == "Bedgraph"){
      if(!all(bedgraphHeader %in% colnames(data))){
        showModal(modalDialog(
          title = "Bedgraph Input File Headers Incorrect",
          tags$p(HTML("The uploaded Bedgraph file does not have the correct header or the wrong separator was chosen when uploading. The required header contains: <b>'chrom','start','stop','value'</b>. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    }
    
  } else if(dataFileType=="ChIP"){
    
    if(input$chipFormat == "Bed"){
      if(!all(bedHeader %in% colnames(data)) | "value" %in% colnames(data)){
        showModal(modalDialog(
          title = "Bed Input File Header Incorrect",
          tags$p(HTML("The uploaded Bed file does not have the correct header or the wrong separator was chosen when uploading. The required header contains: <b>'chrom','start','stop'</b>. If your file contains 'value', the data will plot as Bed format ignoring the 'value' data. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    } else if (input$chipFormat == "Bedgraph"){
      if(!all(bedgraphHeader %in% colnames(data))){
        showModal(modalDialog(
          title = "Bedgraph Input File Headers Incorrect",
          tags$p(HTML("The uploaded Bedgraph file does not have the correct header  or the wrong separator was chosen when uploading. The required header contains: <b>'chrom','start','stop','value'</b>. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    }
    
  } else if(dataFileType=="mRNA"){
    
    if(input$mrnaFormat == "Bed"){
      if(!all(bedHeader %in% colnames(data)) | "value" %in% colnames(data)){
        showModal(modalDialog(
          title = "Bed Input File Header Incorrect",
          tags$p(HTML("The uploaded Bed file does not have the correct header or the wrong separator was chosen when uploading. The required header contains: <b>'chrom','start','stop'</b>. If your file contains 'value', the data will plot as Bed format ignoring the 'value' data. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    } else if (input$mrnaFormat == "Bedgraph"){
      if(!all(bedgraphHeader %in% colnames(data))){
        showModal(modalDialog(
          title = "Bedgraph Input File Headers Incorrect",
          tags$p(HTML("The uploaded Bedgraph file does not have the correct header or the wrong separator was chosen when uploading. The required header contains: <b>'chrom','start','stop','value'</b>. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    }
  }
  
}


# FUNCTION: define function to upload and read gene annotation data file from the
# storage.googleapis.com bucket
readGenes <- function(geneWindow){
  # Read processed Ensembl.biomart.chr file from googleStorage public URL to plot 
  # gene coordinates.
  geneCChNumber_generic = "https://storage.googleapis.com/gencode_ch_data/";
  genCode <- paste(geneCChNumber_generic,"Gencode.",geneWindow$chrom,".txt",sep = "")
  genes <- read.delim(genCode,header=TRUE);
  return(genes)
}

# FUNCTION: define function to set spatial layout for plots
plotLayout <- function(){
  nf <- layout(matrix(c(1,2),2,1,byrow = TRUE), width=c(4), height=c(2,1), respect=TRUE)
  layout.show(nf)
}

# FUNCTION: define function to set margin parameters for data subplot
parPlot <- function(){
  par(mar=c(2,4,4,2));
}

# FUNCTION: define function to set margin parameters for genes subplot
parGenes <- function(){
  par(mar=c(2,4,0,2));
}

# FUNCTION: define function to generate the gene annotations subplot using the plotGenes 
# call from Sushi. Change this function to alter the gene annotation appearance
# The stacking of genes in the plot is controlled by packrow and maxrows. packrow=FALSE 
# will give each gene its own row. packrow=TRUE, maxrows=2 will display all genes on 2 rows
# This function calls the Sushi package
subPlotGenes <- function(genes,geneWindow){
  ## USING SUSHI PACKAGE
  plotGenes(genes,geneWindow$chrom,geneWindow$chromstart,geneWindow$chromend,types=genes$type,plotgenetype="arrow",packrow=FALSE,bheight=0.02,bentline=FALSE,labeloffset=0.1,fontsize=0.5,arrowlength = 0.0025,labelat = "start",labeltext=TRUE,colorby = genes$strand,colorbycol = SushiColors(2))
}

# FUNCTION: define function to generate plot titles 
plotTitles <- function(yAxis="Y title",topTitle="Top title"){
  axis(side=2,las=2,tcl=.2);
  mtext(yAxis,side=2,line=1.75,cex=.75,font=2);
  mtext(topTitle,side=3,line=1.75,cex=0.75,font=2);
}

# FUNCTION: define function to convert gene window parameters defined by coordinates 
# (ByCoord) to numeric values and return the coordinates in an list object
defineGeneWindowByCoord <- function(input){
  chrom = input$chromNumber;
  chromstart = as.numeric(input$cStart);
  chromend = as.numeric(input$cStop);
  geneWindow <- list("chrom" = chrom,"chromstart" = chromstart,"chromend" = chromend)
  return(geneWindow)
}

# FUNCTION: define function that uses a regular expression to extract gene coordinates from 
# geneId (when using search ByGene)
geneCoordinatesByGene <- function(input){
  pattern <- " (.*?):"
  chrom <- regmatches(input$geneId,regexec(pattern,input$geneId))
  pattern <- ":(.*?)-"
  chromstart <- regmatches(input$geneId,regexec(pattern,input$geneId))
  pattern <- "-(.*?)$"
  chromend <- regmatches(input$geneId,regexec(pattern,input$geneId))
  chromCoords <- list("chrom"=chrom[[1]][2],
                      "chromstart"=chromstart[[1]][2],
                      "chromend"=chromend[[1]][2])
  return(chromCoords)
}

# FUNCTION: define function to convert gene window parameters defined by gene search (ByGene) 
# to numeric values and return the coordinates in an list object
defineGeneWindowByGene <- function(input){
  chromCoords <- geneCoordinatesByGene(input)
  chrom = chromCoords$chrom;
  chromstart = as.numeric(chromCoords$chromstart) - as.numeric(input$leftDistance);
  chromend = as.numeric(chromCoords$chromend) + as.numeric(input$rightDistance);
  geneWindow <- list("chrom" = chrom,"chromstart" = chromstart,"chromend" = chromend)
  return(geneWindow)
}


# FUNCTION: define function to generate genome axis label
# This function calls the Sushi package
makeGenomeLabel <- function(geneWindow){
  ## USING SUSHI PACKAGE
  labelgenome(geneWindow$chrom, geneWindow$chromstart,geneWindow$chromend,n=3,scale="Mb");
}


# FUNCTION: define function to create color palette for bezier curves and cytoscape plots
bezierColorPalette <- function(input){
  # The app supports a color palette for 9 different colors. As such the app supports 9 
  # samples per data set. Blue = #377eb8, Red = #e41a1c, Green = #4daf4a, Purple = #984ea3,
  # Orange = #ff7f00, Yellow = #ffff33, Brown = #a65628, Pink = #f781bf, Gray = #999999
  fullPalette <- c("#377eb8", "#e41a1c", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33", "#a65628", "#f781bf", "#999999")
  plotPalette <- fullPalette[1:input$numOfSamples]
  return(plotPalette)
}


# FUNCTION: define function to generate legend for bezier curve plot
bezierLegend <- function(input){
  legendNames <- sapply(1:input$numOfSamples, function(number){
    eval(parse(text = (paste0("input$sNumber", number))))
  })
  color_select <- bezierColorPalette(input)
  legend("topleft",inset =0.1,legend=legendNames,col=color_select,pch=19,bty='n',cex=0.7,text.font=2);
}


# FUNCTION: Define function to plot bezier curves using plotBedpe
# Each plot exists within the window created by plotLayout. The plot device there are two
# subplots with plot margins defined by parPlot() and parGenes(). The upper subplot
# contains the bezier curves, the lower subplot contains the gene annotations.
# This function calls the Sushi package
makeBezierCurves <- function(data,input,genes,geneWindow){
  
  #Call color palette
  color_palette <- bezierColorPalette(input)
  color_select <-colorRampPalette(color_palette)
  
  #Call plot layout
  plotLayout()
  

  ## Bezier curve plot (upper subplot)
  
  #Define margins for upper subplot
  parPlot()
  
  #Sushi colorby and colorbycol requires >= 2 samples, therefore the following conditional 
  # tests if the dataset has 1 or >=2 samples in data$samplenumber. If only 1 sample 
  # in data$samplenumber, then coloring is by `color="blue"`; else coloring is by
  # `colorby=data$samplenumber,colorbycol=color_select`
  if(max(data$samplenumber) == 1){
    #for only 1 sample in data$samplenumber
    ## USING SUSHI PACKAGE
    pbpe = plotBedpe(data,geneWindow$chrom,geneWindow$chromstart,geneWindow$chromend,lwdby = data$score,lwdrange = c(0,2),heights = data$score,plottype="loops",color="blue");
  }else{
    #for >= 2 samples in data$samplenumber
    ## USING SUSHI PACKAGE
    pbpe = plotBedpe(data,geneWindow$chrom,geneWindow$chromstart,geneWindow$chromend,lwdby = data$score,lwdrange = c(0,2),heights = data$score,plottype="loops",colorby=data$samplenumber,colorbycol=color_select);
  }
  
  makeGenomeLabel(geneWindow);
  bezierLegend(input);
  plotTitles(yAxis="Interaction intensity",topTitle="HiC")
  
  
  ## Genes features plot (lower subplot)
  
  # Define margins for lower subplot
  parGenes()
  # Plot gene annotations
  subPlotGenes(genes,geneWindow)
}


# ###-----------   plotBezierCurves and makeBezierCurves could be combined into a single
# function, similar to plotBedgraphWrapper or plotBedWrapper

# FUNCTION: define function to call makeBezierCurves with progress-bars
# Progress bars are a Shiny function
plotBezierCurves <- function(data,input,genes,geneWindow){
  
  withProgress(message = 'Making bezier curve plot', value = 0, {
    
    #Increment progress
    incProgress(0.6)
    
    makeBezierCurves(data, input, genes, geneWindow)
    
    #Increment progress
    incProgress(0.8)
  })
  
}

# FUNCTION: Define a function to plot bedgraph data
# Each plot exists within the window created by plotLayout. Within the plot device there 
# are two subplots with plot margins defined by parPlot() and parGenes(). The upper
# subplot contains the peaks, the lower subplot contains the gene annotations.
# Progress bars are a Shiny function
# This function calls the Sushi package
plotBedgraphWrapper <- function(data, input, genes, geneWindow, plotTopTitle){
  
  withProgress(message = 'Making bedgraph plot', value = 0, {
    
    #Increment progress
    incProgress(0.6)
    
    #Call plot layout
    plotLayout()
    
	
	## Bedgraph plot (upper subplot)
	
    # Define margins for upper subplot
    parPlot()
	
    # Create color palette for Bedgraph peaks
    color_select <-colorRampPalette(c("#FEE0D2", "#FCBBA1", "#FC9272", "#FB6A4A", "#EF3B2C", "#CB181D", "#A50F15", "#67000D"))
    
	## USING SUSHI PACKAGE
    plotBedgraph(data,geneWindow$chrom,geneWindow$chromstart,geneWindow$chromend,colorbycol= color_select)
    makeGenomeLabel(geneWindow);
    plotTitles(yAxis="Read Depth",topTitle=plotTopTitle)
    
	
    ## Genes features plot (lower subplot)
	
    # Define margins for lower subplot
	parGenes()
	# Plot gene annotations
    subPlotGenes(genes,geneWindow)
    
		
    #Increment progress
    incProgress(0.8)
  })
}

#FUNCTION: Define function to plot Bed data
# Each plot exists within the window created by plotLayout. Within the plot device there 
# are two subplots with plot margins defined by parPlot() and parGenes(). The upper 
# subplot contains the peaks, the lower subplot contains the gene annotations.
# Progress bars are a Shiny function
# This function calls the Sushi package
plotBedWrapper <- function(data, input, genes, geneWindow, plotTopTitle){
  
  withProgress(message = 'Making bed plot', value = 0, {
    
    #Increment progress
    incProgress(0.6)
    
    #Call plot layout
    plotLayout()
    
	
    ## Bedgraph plot (upper subplot)
	
	# Define margins for upper subplot
    parPlot()
	
    # Plot bed plot
    ## USING SUSHI PACKAGE
    plotBed(beddata = data,geneWindow$chrom, geneWindow$chromstart,geneWindow$chromend, rownumber = data$row, type = "region", color=data$color,row="given",rowlabels=unique(data$name), rowlabelcol=unique(data$color),rowlabelcex=0.75)
    makeGenomeLabel(geneWindow);
    plotTitles(yAxis="Peaks",topTitle=plotTopTitle)
    
	
    ## Genes features plot (lower subplot)
    
	# Define margins for lower subplot
	parGenes()
	# Plot gene annotations
    subPlotGenes(genes,geneWindow)
    
    #Increment progress
    incProgress(0.8)
  })
}

#**************************** 
# How Shiny Works:
# Shiny applications have two components, a user interface object and a server function, 
# that are passed as arguments to the shinyApp(..) function that creates a Shiny app object 
# from this ui/server pair. The shinyApp(..) call is the last line of code in this file.
# In the following sections, the ui and server functions are defined in separate sections, 
# then passed to the shinyApp(..) function to create the Shiny app object. The pairing of 
# ui and server via the shinyApp(..) function creates the dynamic, reactive interface in 
# the web-browser.

# Resources for learning Shiny: https://shiny.rstudio.com/articles/
# To understand how shinyApp(..) creates a dynamic, reactive Shiny app object read:
# https://shiny.rstudio.com/articles/basics.html
# To understand reactivity read:
# https://shiny.rstudio.com/articles/reactivity-overview.html

#**************************** 
# ui for Shiny
# The ui defines the user interface for the Shiny app object. This creates all the front-end
# HTML that is seen by the user in the web browser.
ui <- fluidPage(title = "Genomic Data Browser", style = "margin:15px;",
                
                ## CSS and JS scripts for Introduction by IntroJS
                # Include IntroJS styling
                includeCSS("www/introjs.css"),
                
                # Include styling for the app
                includeCSS("www/app.css"),
                
                # Include IntroJS library
                includeScript("www/intro.js"),
                
                # Include javascript code to make shiny communicate with introJS
                includeScript("www/app.js"),
                
                # Include javascript code to download Cytoscape network as PNG. From: https://github.com/cytoscape/r-cytoscape.js/tree/master/inst/examples/shiny
                includeScript("www/cyjs.js"),
                
                ##
				# fluidRow containing title image, genome options, help button and reload button
                fluidRow(
                  column(width = 6,
                         img(src="DNARchitect_Logo.png",align="left",height="75px")),
                  column(width = 1,
                         tags$p("")),
                  column(width = 3,
                         selectInput(inputId = "genome",label = "Genome", choices = c("Mouse (mus musculus)"),selected = "Mouse (mus musculus)")),
                  column(width = 2,
                         tags$br(),
                         actionButton(inputId = "startHelp",label = "Help", class="btn-info"), 
                         actionButton(inputId = "reloadApp",label = "Reload App", class="btn-danger"),
                         style = "margin-top: 5px;")
                ),
				# tabsetPanel define the 'Upload File' and 'Plots' tabs
                tabsetPanel(
                  id = "mainTabs",
				  # tabPanel for the 'Upload File' tab
                  tabPanel(title = "Upload File",
				           # fluidRow establishing Step 1, Step 2, and Step 3 panels
						   fluidRow(
                             column(4,
                                    tags$br(),
                                    wellPanel(id="dataTypeWellPanel",
                                      tags$p(HTML("<b>Step 1:</b> Select the types of data you want to analyze, then browse for your files")),
                                      #Select data types
                                      div(id="fileTypesDiv", selectizeInput(inputId="fileTypes","Select Data Types",choices=dataTypes,multiple=TRUE,selected=dataTypes[1])),
                                      style = "height:150px"
                                      )
                                    ),
                             column(4,
                                    tags$br(),
                                    wellPanel(id="processWellPanel",
                                      tags$p(HTML("<b>Step 2:</b> After browsing for your files, click the button to process the data for plotting")),
                                      tags$br(),
                                      actionButton("processDataBtn","Process Data"),
                                      style = "height:150px"
                                      )
                                    ),
                             column(4,
                                    tags$br(),
                                    wellPanel(id="goToPlotWellPanel",
                                      tags$p(HTML("<b>Step 3:</b> Make sure your data looks correctly formatted in the tabs below. Then, click on the Plots tab to visualize your data")),
                                      actionButton(inputId="goToPlots","Go to Plots"),
                                      style = "height:150px"
                                      )  
                                    )
                             ),
							 
				           # fluidRow establishing conditional panels for specifying Bed/Bedgraph
                           fluidRow(
                             conditionalPanel(id="atacFormatPanel", 
                                              condition = "input.fileTypes.includes('ATAC')",
                                              column(4,
                                                     div(id="atacFormatPanelDiv",selectInput(inputId="atacFormat","Select ATAC data format", choices = c("Bed","Bedgraph")))
                                                     )
                                              ),
                             conditionalPanel(id="chipFormatPanel",
                                              condition = "input.fileTypes.includes('ChIP')",
                                              column(4,
                                                     selectInput("chipFormat","Select ChIP data format", choices = c("Bed","Bedgraph"))
                                                     )
                                              ),
                             conditionalPanel(id="mrnaFormatPanel", 
                                              condition = "input.fileTypes.includes('mRNA')",
                                              column(4,
                                                     div(id="mrnaFormatPanelDiv",selectInput(inputId="mrnaFormat","Select mRNA data format", choices = c("Bed","Bedgraph")))
                                              )
                             )
                           ),
                           
                           tags$br(),
						   # uiOutput("dataTabs") dynamically generates tabs to upload each selected Data Type. See the server for backend of this uiOutput.
                           uiOutput("dataTabs")
                  ),
				  
				  # tabPanel for the 'Plots' panel
                  tabPanel(
                    title = "Plots",
                    fluidRow(tags$br()),
					
					# fluidRow creates ui elements for selecting the number of HiC samples, naming the HiC samples, and conditional panels for visualizing genome based on either gene name or coordinates
                    fluidRow(
                      column(3,
                             div(id="numOfSamplesDiv",selectInput(inputId = "numOfSamples", 
                                                   label = "Number of Samples in HiC Dataset",
                                                   choices = c(1,2,3,4,5,6,7,8,9), multiple = FALSE, selectize = TRUE, width = NULL, size = NULL)),
                             checkboxInput("byCoordinates","Search by Coordinates")
                      ),
                      column(3,
                             div(id="sampleNamesDiv", style = "overflow-y:scroll; max-height: 150px",{
                               uiOutput("sampleNames")
                             })
                      ),
                      div(id="searchByCoordinatesDiv",
                          conditionalPanel(
                            condition = "input.byCoordinates == true",
                            column(3,
                                   selectInput(inputId = "chromNumber", 
                                               label = "Chr Number",
                                               choices = c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chrX","chrY"), multiple = FALSE,
                                               selectize = TRUE, width = NULL, size = NULL),
                                   actionButton("submitByCoordinates", "Submit Parameters")
                            ),
                            column(3,
                                   textInput(inputId = "cStart", 
                                             label = "Start coordinate",
                                             value = "60853778"),
                                   textInput(inputId = "cStop", 
                                             label = "End coordinate",
                                             value = "60948071")
                            )
                          )
                          ),
                      div(id="searchByGeneDiv",
                          conditionalPanel(
                            condition = "input.byCoordinates == false",
                            column(3,
                                   div(id="geneIdDiv",
                                       selectizeInput(
                                         'geneId', label = 'Type gene name: (backspace to clear)', choices = geneNames$cat,
                                         options = list(maxOptions = 5, placeholder = 'Type gene name', onInitialize = I('function() { this.setValue(""); }'))
                                       )),
                                   actionButton("submitByGene", "Submit Parameters")
                            ),
                            column(3,
                                   div(id="genomicIntervalDiv",
                                       textInput(inputId = "leftDistance", 
                                                 label = "Genomic interval to left of gene (bases)",
                                                 value = "50000"),
                                       textInput(inputId = "rightDistance", 
                                                 label = "Genomic interval to right of gene (bases)",
                                                 value = "50000")
                                   )  
                            )
                          )
                      )
                    ),
                    
                    fluidRow(tags$hr()),
					#fluidRow defines conditionalPanels for the HiC bezier curve plot and cytoscape network plot
					fluidRow(
                      column(6,
                             conditionalPanel(id="hicPlotPanel",
                                              condition = "input.fileTypes.includes('HiC')",
                                              wellPanel(
                                                downloadButton("downloadDataBezier", "Download Plot"),
                                                tags$hr(),
                                                plotOutput("bezierplot")
                                                )
                                              )
                      ),
                      column(6,
                             conditionalPanel(id="cyNetworkPanel",
                                              condition = "input.fileTypes.includes('HiC')",
                                              wellPanel(
                                                actionButton("saveImage", "Download as PNG"),
                                                actionButton("refreshCytoBtn", "Refresh cytoscape plot"),
                                                tags$hr(),
                                                rcytoscapejsOutput("cyplot", height="400px")
                                                )
                                              )
                      )
                    ),

                    fluidRow(tags$hr()),
					#fluidRow defines conditionalPanels for ATAC data plot and cytoscape 'clicked nodes' table
                    fluidRow(
                      column(6,
                             conditionalPanel(id="atacPlotPanel",
                                              condition = "input.fileTypes.includes('ATAC')",
                                              wellPanel(
                                                downloadButton("downloadDataAtac", "Download Plot"),
                                                tags$hr(),
                                                plotOutput("atacPlot")
                                                )
                                              )
                      ),
                      column(6,
                             conditionalPanel(id="cyClickedNodesPanel",
                                              condition = "input.fileTypes.includes('HiC')",
                                              wellPanel(
                                                h4("Clicked Node"),
                                                verbatimTextOutput("clickedNode"),
                                                h4("Connected Nodes"),
                                                verbatimTextOutput("connectedNodes")
                                                )
                                              )
                             )
                    ),
                    
                    fluidRow(tags$hr()),
					#fluidRow defines conditionalPanels for ChIP-data and mRNA-data plots
                    fluidRow(
                      column(6,
                             conditionalPanel(id="chipPlotPanel",
                                              condition = "input.fileTypes.includes('ChIP')",
                                              wellPanel(
                                                downloadButton("downloadDataChip", "Download Plot"),
                                                tags$hr(),
                                                plotOutput("chipPlot")
                                                )
                                              )
                             ),
                      column(6,
                             conditionalPanel(id="mrnaPlotPanel",
                                              condition = "input.fileTypes.includes('mRNA')",
                                              wellPanel(
                                                downloadButton("downloadDataMrna", "Download Plot"),
                                                tags$hr(),
                                                plotOutput("mrnaPlot")
                                              )
                             )
                      )
                      )
                    
                    )
                )
)

#**************************** 
# server for Shiny
# The server defines the 'server-side' R code for the App. The server calls the FUNCTIONS
# defined previously to perform computation, plotting etc in R. The server is paired with 
# the ui via shinyApp() to deliver R outputs to the ui.
# The server utilizes several functions to control reactivity, including observeEvent.
# The structure is:
#		observeEvent(event,{R code})
# 			The content of the observeEvent {R code}, will only be executed when the event 
#			is invalidated (ie changes)
server <- function(input, output, session) {
  
  
  
  
  ## Reload App when click 'Reload App' button
  observeEvent(input$reloadApp, {
    session$reload()
  })
  
  
  
  
  ## Go to the "Plots" tab when click "goToPlots" button
  observeEvent(input$goToPlots, {
    updateTabsetPanel(session = session, inputId = "mainTabs", selected = "Plots")
  })
  
  
  
  
  ## Render appropriate number of textInput based on number of HiC samples
  output$sampleNames <- renderUI({
    Samples <- lapply(1:input$numOfSamples, function(number){
      textInput(inputId = paste0("sNumber", number), 
                label = paste0("HiC Sample ", number),
                value = "Sample ID")
    })
  })
  
  
  
  ## Server code for Introduction by IntroJS
  # set help content
  session$sendCustomMessage(type = 'setHelpContent', message = list(steps = toJSON(steps) ))
  
  # change Tab as tutorial progresses
  observeEvent(input$changeTab,{
    updateTabsetPanel(session = session, inputId = "mainTabs", selected = "Plots")
  })
  
  # Display help modal when click the 'Help' button
  observeEvent(input$startHelp,{
    
    # The tutorial via IntroJS uses the HiC and ATAC use case scenario, so updateSelectizeInput is used to update fileTypes appropriately 
    updateSelectizeInput(session, inputId="fileTypes",choices=dataTypes,selected=dataTypes[1:2])
    # Tutorial starts on the Upload File tab
    updateTabsetPanel(session = session, inputId = "mainTabs", selected = "Upload File")
    
    showModal(modalDialog(
      title = "Help",
      tags$p(HTML("Click <b>Start Tutorial</b> to begin an interactive introduction to using this app. Sample data, source code and documentation are available at our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a>. <br /><br />Want to analyze more data files simultaneously than this app supports? Just fire up the app in another browser and look at the windows side-by-side! Or download the source code and customize the app to your needs! Hint: the ATAC, ChIP, and mRNA data types actually plot in the same way, so you can plot any bed or bedgraph format data using these options. We are working on allowing the user to define the data type labels themselves, just have not gotten there yet! <br /><br />To exit this help menu click outside the dialog box")),
      footer = actionButton(inputId = "startTutorial","Start Tutorial"),
      easyClose = TRUE
    ))
  })
  
  # Initiate IntroJS tutorial when click the 'Start Tutorial' button
  observeEvent(input$startTutorial,{
    
    removeModal()
    
    req("HiC" %in% input$fileTypes & "ATAC" %in% input$fileTypes)
    
    # on click, send custom message to start help
    session$sendCustomMessage(type = 'startHelp', message = list(""))
  })
  
  
  
  ## Generate dynamic upload UI based on fileTypes selected. This is output in the ui
  #  via the uiOutput("dataTabs")
  output$dataTabs <- renderUI({
	  # By using lapply, the dataTabs will generate 'upload panels' for as many elements 
	  # as there are in the input$fileTypes object
    dataTabs <- lapply(1:length(input$fileTypes), function(i){
      tabPanel(title = input$fileTypes[i],
               
               # Sidebar layout with input and output definitions ----
               sidebarLayout(
                 
                 # Sidebar panel for inputs ----
                 sidebarPanel(
                   
                   # Input: Select a file ----
                   div(id=paste0(input$fileTypes[i],"FileDiv"),
                       fileInput(paste0(input$fileTypes[i],"File"), "Choose a TXT, CSV, or BG File",
                                 multiple = TRUE,
                                 accept = c(".txt","text/csv",
                                            "text/comma-separated-values,text/plain",
                                            ".csv",".bg"))
                   ),
                   
                   # Horizontal line ----
                   tags$hr(),
                   
                   # Input: Checkbox if file has header ----
                   div(id=paste0(input$fileTypes[i],"HeaderDiv"),
                       checkboxInput(paste0(input$fileTypes[i],"Header"), "Header", TRUE)
                   ),
                   
                   # Input: Select separator ----
                   div(id=paste0(input$fileTypes[i],"SepDiv"),
                       radioButtons(paste0(input$fileTypes[i],"Sep"), "Separator",
                                    choices = c(Comma = ",",
                                                Semicolon = ";",
                                                Tab = "\t"),
                                    selected = "\t")
                   ),
                   
                   # Input: Select quotes ----
                   div(id=paste0(input$fileTypes[i],"QuoteDiv"),
                       radioButtons(paste0(input$fileTypes[i],"Quote"), "Quote",
                                    choices = c(None = "",
                                                "Double Quote" = '"',
                                                "Single Quote" = "'"),
                                    selected = '"')
                   ),
                   
                   # Horizontal line ----
                   tags$hr(),
                   
                   # Input: Select number of rows to display ----
                   div(id=paste0(input$fileTypes[i],"DispDiv"),
                       radioButtons(paste0(input$fileTypes[i],"Disp"), "Display",
                                    choices = c(Head = "head",
                                                Tail = "tail"),
                                    selected = "head")
                   )
                 ),
                 
                 # Main panel for displaying outputs ----
                 mainPanel(id=paste0(input$fileTypes[i],"MainPanelDiv"),
                           
                           # # Output: Data file ----
                           tableOutput(paste0(input$fileTypes[i],"Table"))
                           
                 )
                 
               )
      )
    })
	# Use do.call to run the function tabsetPanel with the arguments `dataTabs` 
    do.call(tabsetPanel, dataTabs)
  })
  
  
  
  ## START OF ANALYSIS/VISUALIZATION BLOCK
  observeEvent(input$processDataBtn,{
    
    # Define submitBy variable
    submitBy <- reactiveValues(method="ByGene")
    
	# ###----------- The following if statements could probably be improved with a more
	# general FUNCTION
    # Warning messages if user processes data before files are uploaded
    if("HiC" %in% input$fileTypes && is.null(input$HiCFile)){
      showNotification(ui="Upload incomplete, please upload HiC file before proceeding",duration=5,closeButton=TRUE,type="error")
    }
    
    if("ATAC" %in% input$fileTypes && is.null(input$ATACFile)){
      showNotification(ui="Upload incomplete, please upload ATAC file before proceeding",duration=5,closeButton=TRUE,type="error")
    }
    
    if("ChIP" %in% input$fileTypes && is.null(input$ChIPFile)){
      showNotification(ui="Upload incomplete, please upload ChIP file before proceeding",duration=5,closeButton=TRUE,type="error")
    }
    
    if("mRNA" %in% input$fileTypes && is.null(input$mRNAFile)){
      showNotification(ui="Upload incomplete, please upload mRNA file before proceeding",duration=5,closeButton=TRUE,type="error")
    }
    
    
    #Read all data files into memory...
    withProgress(message = "Processing Data", value = 0.10, {
      
	  # ###----------- The following if statements could probably be improved with a more
	  # general function
      if("HiC" %in% input$fileTypes){
        req(input$HiCFile)
        HiCdata <- HiCdataRead(input);
        output$HiCTable <- renderTable({
          displayUploadedFile(data=HiCdata, input, dataFileType="HiC")
        })
        
        checkHeader(data=HiCdata, dataFileType="HiC", input)
 
      }
      
      #Increment progress
      incProgress(0.25)
      
      if("ATAC" %in% input$fileTypes){
        req(input$ATACFile)
        ATACdata <- ATACdataRead(input);
        output$ATACTable <- renderTable({
          displayUploadedFile(data=ATACdata, input, dataFileType="ATAC")
        })
        
        checkHeader(data=ATACdata, dataFileType="ATAC", input)
        
      }
      
      #Increment progress
      incProgress(0.50)
      
      if("ChIP" %in% input$fileTypes){
        req(input$ChIPFile)
        ChIPdata <- ChIPdataRead(input);
        output$ChIPTable <- renderTable({
          displayUploadedFile(data=ChIPdata, input, dataFileType="ChIP")
        })
        
        checkHeader(data=ChIPdata, dataFileType="ChIP", input)
        
      }
      
      #Increment progress
      incProgress(0.75)
      
      if("mRNA" %in% input$fileTypes){
        req(input$mRNAFile)
        mRNAdata <- mRNAdataRead(input);
        output$mRNATable <- renderTable({
          displayUploadedFile(data=mRNAdata, input, dataFileType="mRNA")
        })
        
        checkHeader(data=mRNAdata, dataFileType="mRNA", input)
        
      }
      
      #Increment progress
      incProgress(0.99)
      
    })
    
    
    ###### REACTIVE FUNCTION: Define reactive function to plot cytoscape network
    plotCyNetwork <- reactive({
      
      withProgress(message = 'Making cytoscape plot', value = 0, {
        
        #Load geneWindow from user defined parameters if input$submitByCoordinates is
		# invalidated, else load by search coordinates if input$submitByGene is 
		# invalidated
        if( submitBy$method == "ByCoord" ){
          geneWindow <- defineGeneWindowByCoord(input);
        } else if ( submitBy$method == "ByGene" ) {
          geneWindow <- defineGeneWindowByGene(input)
        }
        
        chrom = geneWindow$chrom;
        cStart = geneWindow$chromstart;
        cStop = geneWindow$chromend;
        
        #Trim HiCdata by chrom, cStart, and cStop data
        trimmedData <- HiCdata[which(HiCdata$chrom1 == chrom),]
        trimmedData <- trimmedData[which(trimmedData$start1 > cStart),]
        trimmedData <- trimmedData[which(trimmedData$end1 < cStop),]
        trimmedData <- trimmedData[which(trimmedData$start2 > cStart),]
        trimmedData <- trimmedData[which(trimmedData$end2 < cStop),]
        
        # Update HiCdata to equal trimmedData
        HiCdata <- trimmedData
        
        #Make column for color and change color based on samplenumber;
        color_palette <- bezierColorPalette(input)
        HiCdata$color <- HiCdata$samplenumber
        for (i in 1:input$numOfSamples){
          HiCdata <- within(HiCdata, color[samplenumber == i] <- color_palette[i])
        }
        
        #Define node1
        HiCdata$node1 <- paste(HiCdata$chrom1,":",HiCdata$start1,"-",HiCdata$end1, sep = "")
        #Define node2
        HiCdata$node2 <- paste(HiCdata$chrom2,":",HiCdata$start2,"-",HiCdata$end2, sep = "")
        #Define unique nodes (by appending node1 and node2)
        nodes <- unique(append(HiCdata$node1,HiCdata$node2))
        
        id <- nodes
        name <- id
        nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
        
        source <- HiCdata$node1
        target <- HiCdata$node2
        edgeData <- data.frame(source, target, stringsAsFactors=FALSE)
        edgeData$color <- HiCdata$color
        
        ## Code for displaying reactive network of selected node with connected nodes
        # Define network that will be used for displaying connected nodes as = edgeData
        network <- edgeData
        
        # NOTE: Reactive variables used as functions networkReactive(). Code block 
		# taken verbatim from:
		# https://github.com/cytoscape/r-cytoscape.js/tree/master/inst/examples/shiny
        # Start code block from: https://github.com/cytoscape/r-cytoscape.js/tree/master/ins
        networkReactive <- reactive({
          if(is.null(input$connectedNodes)) {
            return(network)
          } else {
            t1 <- which(network$source %in% input$connectedNodes)
            t2 <- which(network$target %in% input$connectedNodes)
            idx <- unique(c(t1, t2))
            return(network[idx,])
          }
        })
        
        output$nodeDataTable <- DT::renderDataTable({
          tmp <- nodeData[which(id == input$clickedNode),]
          DT::datatable(tmp, filter='bottom', style='bootstrap', options=list(pageLength=5))
        })
        
        output$edgeDataTable <- DT::renderDataTable({
          DT::datatable(networkReactive(), filter='bottom', style='bootstrap', options=list(pageLength=5))
        })
        
        output$clickedNode = renderPrint({
          input$clickedNode
        })
        
        output$connectedNodes = renderPrint({
          input$connectedNodes
        }) #End code block from: From: https://github.com/cytoscape/r-cytoscape.js/tree/master/ins
        
        ## Generate cytoscape plots
        cyNetwork <- createCytoscapeJsNetwork(nodeData, edgeData, edgeTargetShape="none")
        rcytoscapejs(cyNetwork$nodes, cyNetwork$edges, showPanzoom=TRUE, highlightConnectedNodes = TRUE, boxSelectionEnabled = TRUE)
        
      })
      
    })
    
    
    ###### REACTIVE FUNCTION: Define reactive function to make all plot calls to appropriate
	# outputs. This was made a reactive function to allow multiple "submit" scenarios 
	# (ie byGene or byCoordinates)
    generatePlots <- reactive({
      
      # Wait for file data (if selected in fileTypes) to exist before proceeding...
      if("HiC" %in% input$fileTypes){
        req(HiCdata)
      }
      if("ATAC" %in% input$fileTypes){
        req(ATACdata)
      }
      if("ChIP" %in% input$fileTypes){
        req(ChIPdata)
      }
      if("mRNA" %in% input$fileTypes){
        req(mRNAdata)
      }
      
      #Load geneWindow from user defined parameters if input$submitByCoordinates is 
	  # invalidated, else load by search coordinates if input$submitByGene is invalidated
      if( submitBy$method == "ByCoord" ){
        geneWindow <- defineGeneWindowByCoord(input);
      } else if ( submitBy$method == "ByGene" ) {
        geneWindow <- defineGeneWindowByGene(input)
      }
      
      #Load gene annotation data for user defined region
      genes <- readGenes(geneWindow)
      
      ######## ATAC Plot Output:
      output$atacPlot <- renderPlot({
        isolate({ 
          if( input$atacFormat == "Bedgraph" ){
            plotBedgraphWrapper(data=ATACdata, input, genes, geneWindow, plotTopTitle = "ATAC-seq Data") 
          } else if ( input$atacFormat == "Bed" ){
            plotBedWrapper(data=ATACdata, input, genes, geneWindow, plotTopTitle = "ATAC-seq Data")
          }
          })
      })
      
      output$downloadDataAtac <- downloadHandler(
        filename = function() {
          "atac_plot.svg"
        },
        content = function(file) {
          svg(file)
          if( input$atacFormat == "Bedgraph" ){
            plotBedgraphWrapper(data=ATACdata, input, genes, geneWindow, plotTopTitle = "ATAC-seq Data") 
          } else if ( input$atacFormat == "Bed" ){
            plotBedWrapper(data=ATACdata, input, genes, geneWindow, plotTopTitle = "ATAC-seq Data")
          }
          dev.off()
        }
      )
      
      ######## ChIP Plot Output:
      output$chipPlot <- renderPlot({
        isolate({ 
          if( input$chipFormat == "Bedgraph" ){
            plotBedgraphWrapper(data=ChIPdata, input, genes, geneWindow, plotTopTitle = "ChIP-seq Data") 
          } else if ( input$chipFormat == "Bed" ){
            plotBedWrapper(data=ChIPdata, input, genes, geneWindow, plotTopTitle = "ChIP-seq Data")
          }
          })
      })
      
      output$downloadDataChip <- downloadHandler(
        filename = function() {
          "chip_plot.svg"
        },
        content = function(file) {
          svg(file)
          if( input$chipFormat == "Bedgraph" ){
            plotBedgraphWrapper(data=ChIPdata, input, genes, geneWindow, plotTopTitle = "ChIP-seq Data") 
          } else if ( input$chipFormat == "Bed" ){
            plotBedWrapper(data=ChIPdata, input, genes, geneWindow, plotTopTitle = "ChIP-seq Data")
          }
          dev.off()
        }
      )
      
      ######## mRNA Plot Output:
      output$mrnaPlot <- renderPlot({
        isolate({ 
          if( input$mrnaFormat == "Bedgraph" ){
            plotBedgraphWrapper(data=mRNAdata, input, genes, geneWindow, plotTopTitle = "mRNA-seq Data") 
          } else if ( input$mrnaFormat == "Bed" ){
            plotBedWrapper(data=mRNAdata, input, genes, geneWindow, plotTopTitle = "mRNA-seq Data")
          }
        })
      })
      
      output$downloadDataMrna <- downloadHandler(
        filename = function() {
          "mrna_plot.svg"
        },
        content = function(file) {
          svg(file)
          if( input$mrnaFormat == "Bedgraph" ){
            plotBedgraphWrapper(data=mRNAdata, input, genes, geneWindow, plotTopTitle = "mRNA-seq Data") 
          } else if ( input$mrnaFormat == "Bed" ){
            plotBedWrapper(data=mRNAdata, input, genes, geneWindow, plotTopTitle = "mRNA-seq Data")
          }
          dev.off()
        }
      )
      
      ####### Cytoscape Network Output:
      output$cyplot <- renderRcytoscapejs({
        isolate({ 
          
          #tryCatch error handling for "Error: replacement has 1 row, data has 0", which 
		  # occurs when the genome window contains no nodes
          tryCatch(
            {
              plotCyNetwork()
            },
            error=function(e) {
              stop("The genomic window does not contain any nodes")
            })
          
          })
      })
      
      ######## Bezier Curve Plot Output:
      output$bezierplot <- renderPlot({
        
        isolate({

          #tryCatch error handling for "Error: replacement has 1 row, data has 0", which 
		  # occurs when the genome window contains no nodes
          tryCatch(
            {
              plotBezierCurves(data=HiCdata, input, genes, geneWindow)
            },
            error=function(e) {
              stop("Current genomic window cannot be plotted, probably because an anchor crosses the plot boundary. Adjust genomic window coordinates (zoom in or out) and re-submit")
            })

          })
      })
      
      output$downloadDataBezier <- downloadHandler(
        filename = function() {
          "bezier_plot.svg"
        },
        content = function(file) {
          svg(file)
          plotBezierCurves(data=HiCdata, input, genes, geneWindow)
          dev.off()
        }
      )
      
    })
    
    
    ###### REACTIVE FUNCTION: Define reactive function to refresh cytoscape plot by 
	# creating a dependency on only input$refreshCytoBtn
	# A dependency is created in a reactive function by placing the variable at the very
	# beginning of the reactive function. The reactive function will be executed whenever
	# that object is invalidated.
    refreshCytoscape <- reactive({
      
      ## Create dependency on input$refreshCytoBtn
      input$refreshCytoBtn
      
      ####### Cytoscape Network Output:
      output$cyplot <- renderRcytoscapejs({
        isolate({ 
          
          #tryCatch error handling for "Error: replacement has 1 row, data has 0", 
		  # which occurs when the genome window contains no nodes
          tryCatch(
            {
              plotCyNetwork()
            },
            error=function(e) {
              stop("The genomic window does not contain any nodes")
            })
          
        })
      })
    })
    
    ######Execute code to Generate Plots Once Press submitByCoordinates actionButton
    observeEvent(input$submitByCoordinates, {
      submitBy$method = "ByCoord"
      generatePlots()
      
      ######Execute code to refresh cytoscape plot Once Press refreshCytoBtn actionButton
      observeEvent(input$refreshCytoBtn, {
        refreshCytoscape()
      })
      
    })
    
    
    ######Execute code to Generate Plots Once Press submitByGene actionButton
    observeEvent(input$submitByGene, {
      submitBy$method = "ByGene"
      generatePlots()
      
      ######Execute code to refresh cytoscape plot Once Press refreshCytoBtn actionButton
      observeEvent(input$refreshCytoBtn, {
        refreshCytoscape()
      })
      
    })
    
    
    ####### Download Cytoscape Network as PNG (uses cyjs.js script in UI). From
	# https://github.com/cytoscape/r-cytoscape.js/tree/master/inst/examples/shiny
    observeEvent(input$saveImage, {
      # NOTE: Message cannot be an empty string "", nothing will happen    
      session$sendCustomMessage(type="saveImage", message="NULL")
    })

    
  })

}

#**************************** 
# Shiny applications have two components, a user interface object and a server function, 
# that are passed as arguments to the shinyApp function that creates a Shiny app object 
# from this UI/server pair.
shinyApp(ui = ui, server = server)