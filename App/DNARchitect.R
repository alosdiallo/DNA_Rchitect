# DNA Rchitect Developer Version

############ ISSUES:
## 1. Add expected input and expected output
## 2. For functions that don't return anything, add a return of 1 or 0 for success or failure --> consider using a try-catch setup   ## val=0, try (... val=1), catch (... val=0), return(val)

## Priorities: 1. Function success/failure codes

# ## Check for and install required packages from CRAN
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
#By Karni: You have to install few bioconductor packages in case they are not installed by the command biocLite(): "stringi", "S4Vectors"
#source("https://bioconductor.org/biocLite.R")
#install.packages(stringi,dependencies=TRUE)
#biocLite("S4Vectors")
#can't load package biomaRt > install.packages("biomaRt)

#To exit the tutorial (after pressing 'Help' Button), you need to click on the page

# # Packages from github
# library("devtools");
# if (!require("rcytoscapejs")) devtools::install_github("cytoscape/r-cytoscape.js")

#library("rcytoscapejs", lib.loc="C:/Users/User/Desktop/DNARchitect_Test/www")

#install.packages("stringi")
#install.packages("shinycssloaders)
#cALL all JS functions from R 
#install.packages("V8")
#install.packages("shinyjs") 

#Before deploying it I had to install
#install.packages("rjson")
#install.packages("rJava")
#install.packages("paxtoolsr")

#library(BioNet) #to save network in XGMML file format
## Load libraries
library(shiny)
library(htmlwidgets)
library(zoo)
library(biomaRt)
library(graph)   #to save the network
library(BioNet)  #to save the network
library(methods)
library(base)
library(DT) #Load DataTables for data-table functions
library(V8) #Embedded JavaScript Engine for R
library(shinyjs) #Use JavaScript operations in Shiny apps
library(jsonlite) # Load jsonlite for JSON communication in IntroJS
library(Sushi) #Load sushi for plot functions (BioconductoR)
library(igraph)
library(graph)
library(ggplot2)
library(shinyBS)
library(iotools)
library(devtools)
library(data.table)
library(shinycssloaders)
library(shinycustomloader)
library(biomaRt)
library(packrat)
library(MASS)
library(gridExtra)
library(latexpdf)



# Create help data frame with steps for IntroJS introduction/tutorial
steps <- read.csv(file="www/help.csv",header=TRUE,sep=",",quote='"')

#Set maximum upload size to 1000 mb
options(shiny.maxRequestSize = 1000*1024^2)

# Create dataTypes object to define choices for fileTypes selectizeInput
dataTypes <- c("HiC","ATAC","ChIP","mRNA")

#FUNCTION: Define function to read uploaded file, only after it has been uploaded
reqRead <- function(input, dataFileType){
  
  #Wait until input$HiCFile exists before proceeding...
  req(eval(parse(text = (paste0("input$", dataFileType, "File")))))
  
  data <- read.delim(
    file =eval(parse(text = (paste0("input$", dataFileType, "File", "$datapath")))), #ByKarni: added attr file to be more clear about the attributes that (read.delim function) has
    header = eval(parse(text = (paste0("input$", dataFileType, "Header")))),
    sep = eval(parse(text = (paste0("input$", dataFileType, "Sep")))),
    quote = eval(parse(text = (paste0("input$", dataFileType, "Quote")))))
  
  return(data)
}

#Read geneNames file for search function
#geneNames <- NULL
#geneNames$mouse <- read.delim("https://storage.googleapis.com/gencode_ch_data/mouse/mouse_searchNames.txt",header=FALSE,stringsAsFactors = FALSE, sep="\t")
#geneNames$human <- read.delim("https://storage.googleapis.com/gencode_ch_data/human/human_searchNames.txt",header=FALSE,stringsAsFactors = FALSE, sep="\t")
#geneNames$drosophila_melanogaster <- read.delim("https://storage.googleapis.com/gencode_ch_data/drosophila_melanogaster/drosophila_searchNames.txt",header=FALSE,stringsAsFactors = FALSE, sep="\t")

mousegenes <- read.csv.raw(file = "www/mouse_searchNames.txt", header = FALSE)
humangenes <- read.csv.raw(file = "www/human_searchNames.txt", header = FALSE)
drosophilagenes <- read.csv.raw(file = "www/drosophila_searchNames.txt", header = FALSE)
names(mousegenes) <- " "
names(humangenes) <- " "
names(drosophilagenes) <- " "


#FUNCTION: Define function to handle HiC data reading. Note dataFileType must be specified because the reqRead function is general and requires specification of dataFileType
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

#FUNCTION: Define function to handle ATAC data reading. Note dataFileType must be specified because the reqRead function is general and requires specification of dataFileType
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

#FUNCTION: Define function to handle ChIP data reading. Note dataFileType must be specified because the reqRead function is general and requires specification of dataFileType
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

#FUNCTION: Define function to handle mRNA data reading. Note dataFileType must be specified because the reqRead function is general and requires specification of dataFileType
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

#FUNCTION: Define function to display head or tail or uploaded file
displayUploadedFile <- function(data, input, dataFileType){
  # input$HiCFile will be NULL initially. After the user selects and uploads a file, head of that data file by default, or tail if selected, will be shown
  
  # Wait until input$HiCFile exists before proceeding...
  req(eval(parse(text = (paste0("input$", dataFileType, "File")))))
  
  if(eval(parse(text = (paste0("input$", dataFileType, "Disp")))) == "head") {
    return(head(data))
  }
  else {
    return(tail(data))
  }
}

#FUNCTION: Check if uploaded file contains required column headers
checkHeader <- function(data, dataFileType, input){
  
  # Possible dataFileType: "HiC","ATAC","ChIP","mRNA"
  # Possible formats: "Bedpe","Bed","Bedgraph"
  
  #Header requirements
  bedpeHeader <- c("chrom1","start1","end1","chrom2","start2","end2","score","samplenumber")
  bedHeader <- c("chrom","start","stop")
  bedgraphHeader <- c("chrom","start","stop","value")
  
  
  if(dataFileType=="HiC"){
    
    if(!all(bedpeHeader %in% colnames(data))){
      showModal(modalDialog(
        title = "Bedpe Input File Header Incorrect",
        tags$p(HTML("The uploaded Bedpe file does not have the correct header. The required header contains: <b>'chrom1','start1','end1','chrom2','start2','end2','score','samplenumber'</b>. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
        easyClose = TRUE
      ))
    }
    
  } else if(dataFileType=="ATAC"){
    
    if(input$atacFormat == "Bed"){
      if(!all(bedHeader %in% colnames(data)) | "value" %in% colnames(data)){
        showModal(modalDialog(
          title = "Bed Input File Header Incorrect",
          tags$p(HTML("The uploaded Bed file does not have the correct header. The required header contains: <b>'chrom','start','stop'</b>. If your file contains 'value', the data will plot as Bed format ignoring the 'value' data. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
        
      }
    } else if (input$atacFormat == "Bedgraph"){
      if(!all(bedgraphHeader %in% colnames(data))){
        showModal(modalDialog(
          title = "Bedgraph Input File Headers Incorrect",
          tags$p(HTML("The uploaded Bedgraph file does not have the correct header. The required header contains: <b>'chrom','start','stop','value'</b>. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    }
    
  } else if(dataFileType=="ChIP"){
    
    if(input$chipFormat == "Bed"){
      if(!all(bedHeader %in% colnames(data)) | "value" %in% colnames(data)){
        showModal(modalDialog(
          title = "Bed Input File Header Incorrect",
          tags$p(HTML("The uploaded Bed file does not have the correct header. The required header contains: <b>'chrom','start','stop'</b>. If your file contains 'value', the data will plot as Bed format ignoring the 'value' data. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    } else if (input$chipFormat == "Bedgraph"){
      if(!all(bedgraphHeader %in% colnames(data))){
        showModal(modalDialog(
          title = "Bedgraph Input File Headers Incorrect",
          tags$p(HTML("The uploaded Bedgraph file does not have the correct header. The required header contains: <b>'chrom','start','stop','value'</b>. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    }
    
  } else if(dataFileType=="mRNA"){
    
    if(input$mrnaFormat == "Bed"){
      if(!all(bedHeader %in% colnames(data)) | "value" %in% colnames(data)){
        showModal(modalDialog(
          title = "Bed Input File Header Incorrect",
          tags$p(HTML("The uploaded Bed file does not have the correct header. The required header contains: <b>'chrom','start','stop'</b>. If your file contains 'value', the data will plot as Bed format ignoring the 'value' data. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    } else if (input$mrnaFormat == "Bedgraph"){
      if(!all(bedgraphHeader %in% colnames(data))){
        showModal(modalDialog(
          title = "Bedgraph Input File Headers Incorrect",
          tags$p(HTML("The uploaded Bedgraph file does not have the correct header. The required header contains: <b>'chrom','start','stop','value'</b>. Please see our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a> for details on file formats and header requirements. <br /><br /> The header must be exactly as specified in the documentation")),
          easyClose = TRUE
        ))
      }
    }
  }
}

#FUNCTION: to read gene annotation data from Ensembl.biomart.chr file
readGenes <- function(geneWindow, input){
  # Read Ensembl.biomart.chr file from googleStorage public URL to plot gene coordinates (Ensembl.biomart.chr files are available for all mouse genes per chromosome.)
  
  # The final URL after pasting all elements together will look like (for mouse):
  # https://storage.googleapis.com/gencode_ch_data/mouse/Gencode.chr1.txt
  
  geneCChNumber_generic = "https://storage.googleapis.com/gencode_ch_data/";
  genCode <- paste(geneCChNumber_generic ,input$genome,"/Gencode.",geneWindow$chrom,".txt",sep = "")
  genes <- read.delim(genCode,header=TRUE);
  return(genes)
}

#FUNCTION: define spatial layout for plots
plotLayout <- function(){
  nf <- layout(matrix(c(1,2),2,1,byrow = TRUE), width=c(4), height=c(2,1), respect=TRUE)
  layout.show(nf)
}

#FUNCTION: define margina parameters for data subplot
parPlot <- function(){
  par(mar=c(2,4,4,2));
}

#FUNCTION: define margin parameters for genes subplot
parGenes <- function(){
  par(mar=c(2,4,0,2));
}

#FUNCTION: plotGenes subplot: maxrows=2, packrow=TRUE vs. packrow=FALSE
subPlotGenes <- function(genes,geneWindow){
  plotGenes(geneinfo =  genes,chrom =  geneWindow$chrom,chromstart =  geneWindow$chromstart,chromend =  geneWindow$chromend, types=genes$type,plotgenetype="arrow",packrow=FALSE,bheight=0.02,bentline=FALSE,labeloffset=0.1,fontsize=0.6,arrowlength = 0.0025,labelat = "start",labeltext=TRUE,colorby = genes$strand,colorbycol = SushiColors(2))
}

#FUNCTION: define plot titles
plotTitles <- function(yAxis="Y title",topTitle="Top title"){
  axis(side=2,las=2,tcl=.2);
  mtext(yAxis,side=2,line=1.75,cex=.75,font=2);
  mtext(topTitle,side=3,line=1.75,cex=0.75,font=2);
}

#FUNCTION: convert gene window parameters by coordinates (ByCoord) to numeric values
defineGeneWindowByCoord <- function(input){
  chrom = input$chromNumber;
  chromstart = as.numeric(input$cStart); #Note that commandArgs makes everything a string, so must convert to numeric
  chromend = as.numeric(input$cStop);
  geneWindow <- list("chrom" = chrom,"chromstart" = chromstart,"chromend" = chromend)
  return(geneWindow)
}

#FUNCTION: regular expression to extract gene coordinates from geneId (when using search by gene)
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

#FUNCTION: convert gene window parameters by gene search (ByGene) to numeric values
defineGeneWindowByGene <- function(input){
  chromCoords <- geneCoordinatesByGene(input)
  chrom = chromCoords$chrom;
  chromstart = as.numeric(chromCoords$chromstart) - as.numeric(input$leftDistance);
  chromend = as.numeric(chromCoords$chromend) + as.numeric(input$rightDistance);
  geneWindow <- list("chrom" = chrom,"chromstart" = chromstart,"chromend" = chromend)
  return(geneWindow)
}


#FUNCTION: generate genome axis label
makeGenomeLabel <- function(geneWindow){
  labelgenome(geneWindow$chrom, geneWindow$chromstart,geneWindow$chromend,n=3,scale="Mb");
}


#FUNCTION: Define color palette for bezier curve samples
bezierColorPalette <- function(input){
  # Blue = #377eb8, Red = #e41a1c, Green = #4daf4a, Purple = #984ea3, Orange = #ff7f00, Yellow = #ffff33, Brown = #a65628, Pink = #f781bf, Gray = #999999
  fullPalette <- c("#377eb8", "#e41a1c", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33", "#a65628", "#f781bf", "#999999")
  plotPalette <- fullPalette[1:input$numOfSamples]
  return(plotPalette)
}


#FUNCTION: generate legend for bezier curves
bezierLegend <- function(input){
  legendNames <- sapply(1:input$numOfSamples, function(number){
    eval(parse(text = (paste0("input$sNumber", number))))
  })
  color_select <- bezierColorPalette(input)
  legend("topleft",inset =0.1,legend=legendNames,col=color_select,pch=19,bty='n',cex=0.7,text.font=2);
}


#FUNCTION: to make bezier curves plots
#Define function to plot bezier curves
makeBezierCurves <- function(data,input,genes,geneWindow){
  
  #Call color palette
  color_palette <- bezierColorPalette(input)
  color_select <-colorRampPalette(color_palette)
  
  #Call plot layout
  plotLayout()
  
  
  ##Bezier curve plots
  parPlot()
  
  #Sushi colorby and colorbycol requires >= 2 samples, therefore the following conditional tests if the dataset has 1 or >=2 samples in data$samplenumber. If only 1 sample in data$samplenumber, then coloring is by `color="blue`; else coloring is by `colorby=data$samplenumber,colorbycol=color_select`
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
  
  
  ## Genes features plot
  parGenes()
 # if (input$genome == "mouse" || "human"){
    subPlotGenes(genes,geneWindow)
#  }
}


#FUNCTION: to call makeBezierCurves with progress-bars
plotBezierCurves <- function(data,input,genes,geneWindow){
  
  withProgress(message = 'Making bezier curve plot', value = 0, {
    
    #Increment progress
    incProgress(0.6)
    
    makeBezierCurves(data, input, genes, geneWindow)
    
    #Increment progress
    incProgress(0.8)
  })
  
}

#FUNCTION: Define function to plot bedgraph data
plotBedgraphWrapper <- function(data, input, genes, geneWindow, plotTopTitle){
  
  withProgress(message = 'Making bedgraph plot', value = 0, {
    
    #Increment progress
    incProgress(0.6)
    
    #Call plot layout
    plotLayout()
    
    # Atac curve plot
    parPlot()
    #Plot Atac-seq plot
    color_select <-colorRampPalette(c("#FEE0D2", "#FCBBA1", "#FC9272", "#FB6A4A", "#EF3B2C", "#CB181D", "#A50F15", "#67000D"))
    ## USING SUSHI PACKAGE
    plotBedgraph(data,geneWindow$chrom,geneWindow$chromstart,geneWindow$chromend,colorbycol= color_select)
    makeGenomeLabel(geneWindow);
    plotTitles(yAxis="Read Depth",topTitle=plotTopTitle)
    
    # Genes features plot
    parGenes()
    subPlotGenes(genes,geneWindow)
    
    #Increment progress
    incProgress(0.8)
  })
}

#FUNCTION: Define function to plot Bed data
plotBedWrapper <- function(data, input, genes, geneWindow, plotTopTitle){
  
  withProgress(message = 'Making bed plot', value = 0, {
    
    #Increment progress
    incProgress(0.6)
    
    #Call plot layout
    plotLayout()
    
    # ChIP curve plot
    parPlot()
    #Plot ChIP-seq plot
    ## USING SUSHI PACKAGE
    plotBed(beddata = data,geneWindow$chrom, geneWindow$chromstart,geneWindow$chromend, rownumber = data$row, type = "region", color=data$color,row="given",rowlabels=unique(data$name), rowlabelcol=unique(data$color),rowlabelcex=0.75)
    makeGenomeLabel(geneWindow);
    plotTitles(yAxis="Peaks",topTitle=plotTopTitle)
    
    # Genes features plot
    parGenes()
    subPlotGenes(genes,geneWindow)
    
    #Increment progress
    incProgress(0.8)
  })
}

#Inlcude Styling for Loading Page content 
appCSS <- "
#loading-content {
position: absolute;
background: #FFFFFF;
z-index: 100;
left: 0;
right: 0;
height: 400%;
text-align: center;
color: #000000;
}
"


# UI for Shiny
ui <- fluidPage(title = "Genomic Data Browser", style = "margin:15px;",
                
                useShinyjs(),
                inlineCSS(appCSS),
                
                # Loading Screen message
                div(
                  id = "loading-content",
                  h2("Loading...")
                ),
                
                #JS script for Introduction by IntroJS
                # Include IntroJS library
                includeScript("www/js/intro.js"),
                
                # Include javascript code to download Cytoscape network as PNG, to make shiny communicate with introJS.
                includeScript(path = "www/js/script.js"),
                
                # Include styling for the app
                includeCSS(path = "www/css/style.css"),   
                
                includeHTML(path = "www/html/include.html"),
                
                
                
                # The main app code goes here
                fluidRow(
                  column(width = 8,
                         img(id = "image", src="DNARchitect_Logo.png"),
                         tags$p("")
                  ),
                  column(width = 2,
                         selectInput(inputId = "genome",label = "Genome", choices = c("mouse","human","drosophila_melanogaster"), selected = "mouse")
                  ),
                  column(width = 2,
                         tags$br(),
                         div(id = "helpreload",
                             actionButton(inputId = "startHelp",label = "Help", class="btn-info"), 
                             actionButton(inputId = "reloadApp",label = "Reload App", class="btn-danger"))
                  )
                ),
                tabsetPanel(
                  id = "mainTabs",
                  tabPanel(title = "Upload File",
                           fluidRow(
                             column(width =4,   
                                    tags$br(),
                                    div(id = "datatypewellpanel", 
                                        wellPanel(id="dataTypeWellPanel", 
                                                  tags$html("Step 1: Select the types of data you want to analyze"),
                                                  tags$br(),
                                                  selectizeInput(inputId="fileTypes",label ="Select Data Types",choices=c("HiC", "ATAC", "ChIP", "mRNA"),multiple = TRUE, selected=dataTypes[1])
                                        )
                                    )
                             ),
                             column(width =4,
                                    tags$br(),
                                    div(id = "processwellpanel", 
                                        wellPanel(id="processWellPanel",
                                                  tags$html("Step 2: After browsing for your files, click the button to process the data for plotting"),
                                                  tags$br(),
                                                  tags$br(),
                                                  actionButton(inputId = "processDataBtn",label = "Process Data")
                                        )
                                    )
                             ),
                             column(width =4,
                                    tags$br(),
                                    div(id= "gotoplotwellpanel",
                                        wellPanel(id="goToPlotWellPanel",
                                                  tags$html("Step 3: Make sure your data looks correctly formatted in the tabs below. Then, click on the Plots tab to visualize your data"),
                                                  tags$br(),
                                                  tags$br(),
                                                  actionButton(inputId="goToPlots",label = "Go to Plots")
                                        )
                                    )  
                             )
                           ),
                           
                           fluidRow(
                             column(width =4,
                                    div(id="atacFormatPanelDiv",  style = "display:none",
                                        selectInput(inputId="atacFormat",label = "Select ATAC data format", choices = c("Bed","Bedgraph"))
                                    ),
                                    div(id ="chipFormatPanelDiv", style = "display:none",
                                        selectInput(inputId = "chipFormat",label = "Select ChIP data format", choices = c("Bed","Bedgraph"))
                                    ),
                                    div(id="mrnaFormatPanelDiv", style = "display:none",
                                        selectInput(inputId="mrnaFormat",label = "Select mRNA data format", choices = c("Bed","Bedgraph"))
                                    )
                             )
                           ),
                           
                           tags$br(),
                           uiOutput(outputId = "dataTabs")
                  ),
                  tabPanel(
                    title = "Plots",
                    fluidRow(tags$br()),
                    fluidRow(
                      column(width =3,
                             div(id="numOfSamplesDiv",
                                 selectInput(inputId = "numOfSamples", 
                                             label = "Number of Samples in HiC Dataset",
                                             choices = c(1,2,3,4,5,6,7,8,9), multiple = FALSE, selectize = TRUE, width = NULL, size = NULL)),
                             tags$br(),
                             radioButtons(inputId = "searchby", label = "Search By: ", choices =  c("Coordinates", "Genes"), selected = "Coordinates")
                             ),
                      column(width =3,
                             div(id="sampleNamesDiv",
                                 uiOutput(outputId = "sampleNames")
                             )
                             
                      ),
                      
                             div(id="searchByCoordinatesDiv", 
                                 column(width =3,
                                 uiOutput(outputId = "chromNumberUI"),
                                 includeHTML(path = "www/html/numericCoord.html")         
                                 )
                             ),
                     
                      div(id="geneIdDiv",
                          column(width=3, 
                                 withLoader(ui_element = uiOutput("searchNamesList"), type = "image", loader = "Loading.png", proxy.height = "100px"),
                                  # uiOutput("searchNamesList"),
                                 includeHTML(path = "www/html/numericDistance.html")
                          )
                      )
                             ),
                    
                    fluidRow(tags$hr()),
                    fluidRow(
                      column(width =6,
                             div ( id= "HiCplot", style="display:none" ,
                                   wellPanel(
                                     downloadButton(outputId = "downloadDataBezier",label =  "Download Plot"),
                                     tags$hr(),
                                     plotOutput(outputId = "bezierplot", height="800px")
                                   )
                             )
                      ),
                      column(width =6,
                             div(id = "HiCNetwork", style="display:none" ,
                                 wellPanel(
                                   tabsetPanel( id = "MainNetwork",
                                     tabPanel(title = "Network",
                                              plotOutput(outputId = "cyplot", height="800px"),
                                              tags$br(),
                                              downloadButton(outputId = "downloadNetwork",label =  "Download as PNG"),
                                              downloadButton(outputId = "downloadAll",label =  "Download All as PDF", style = "float:right"),
                                              downloadButton(outputId = "download_xgmml", label = "Download Network as XGMML")
                                              ),
                                     tabPanel(title = "Hubs",
                                              plotOutput(outputId = "plotHubs", height = "800px"),
                                              tags$br(),
                                              downloadButton(outputId = 'downloadPlot_hub', label = 'Download as PNG')
                                              ),
                                     tabPanel(title = "Degree Distribution",
                                              plotOutput(outputId = "plotdegree", height = "800px"),
                                              tags$br(), 
                                              downloadButton(outputId = 'downloadPlot_degree', label = 'Download as PNG')
                                              ),
                                     tabPanel(title = "Groups",
                                              plotOutput(outputId = "plotgroups", height = "800px"),
                                              tags$br(), 
                                              downloadButton(outputId = 'downloadPlot_groups', label = 'Download as PNG'),
                                              actionButton(inputId = "Extract_info", label = "Membership Data", style = "float:right"), 
                                              bsModal(id = "extract_labels", title = "Community Membership for each node", trigger = "Extract_info", size = "large", tableOutput(outputId = "membership_data"))
                                              ),
                                     tabPanel(title = "Node Degree",
                                              plotOutput(outputId = "plotNodeDegree", height = "800px"),
                                              tags$br(), 
                                              downloadButton(outputId = 'downloadPlot_node_degree', label = 'Download as PNG')
                                              )
                                   )

                                 )
                             )
                      )
                    ),
                    fluidRow(tags$hr()),
                    fluidRow(
                      column(width =6,  
                             div (id = "ATACPlot", style="display:none" ,
                                  wellPanel(
                                    downloadButton(outputId = "downloadDataAtac", label = "Download Plot"),
                                    tags$hr(),
                                    plotOutput(outputId = "atacPlot", height="800px")  
                                  )
                             )
                      )
                    ),
                    fluidRow(tags$hr()),
                    fluidRow(
                      column(width =6,
                             div (id = "ChIPPlot",  style="display:none" ,
                                  wellPanel(
                                    downloadButton(outputId = "downloadDataChip", label = "Download Plot"),
                                    tags$hr(),
                                    plotOutput(outputId = "chipPlot", height="800px")  
                                  )
                             )
                      ),
                      column(width =6,
                             div (id = "mRNAPlot",  style="display:none" ,
                                  wellPanel(
                                    downloadButton(outputId = "downloadDataMrna",label =  "Download Plot"),
                                    tags$hr(),
                                    plotOutput(outputId = "mrnaPlot", height="800px")  
                                  )
                             )
                      )
                    )
                             )
                             )
                )

server <- function(input, output, session) {
  
  # Hide the loading message when the rest of the server function has executed
  hide(id = "loading-content", anim = TRUE, animType = "fade") 
  
  # Reload App
  observeEvent(input$reloadApp, {
    session$reload()
  })
  
  ## Go to the "Plots" tab when click "goToPlots" button
  observeEvent(input$goToPlots, {
    updateTabsetPanel(session = session, inputId = "mainTabs", selected = "Plots")
  })
  
  ## Render appropriate number of textInput based on number of samples
  output$sampleNames <- renderUI({
    Samples <- lapply(1:input$numOfSamples, function(number){
      textInput(inputId = paste0("sNumber", number), 
                label = paste0("HiC Sample ", number),
                value = "Sample ID")
      
    })
  })
  #Dynamic UI elements are suspended by default, when suspendWhenHidden = TRUE they are released Needtochange
  outputOptions(output, "sampleNames", suspendWhenHidden = FALSE) 
  
  
  # outputOptions(output, "searchNamesList", suspendWhenHidden = FALSE)
  
  ## Server code for Introduction by IntroJS
  # set help content
  session$sendCustomMessage(type = 'setHelpContent', message = list(steps = toJSON(steps) ))
  
  # change Tab as tutorial progresses
  observeEvent(input$changeTab,{
    updateTabsetPanel(session = session, inputId = "mainTabs", selected = "Plots")
  })
  
  # Display help modal
  observeEvent(input$startHelp,{
    
    # The tutorial via IntroJS uses the HiC and ATAC use case scenario, so updateSelectizeInput is used to update fileTypes appropriately 
    updateSelectizeInput(session, inputId="fileTypes",choices=dataTypes,selected=dataTypes[1:2])
    # Tutorial starts on the Upload File tab
    updateTabsetPanel(session = session, inputId = "mainTabs", selected = "Upload File")
    showModal(modalDialog(
      title = "Help",
      tags$p(HTML("Click <b>Start Tutorial</b> to
                  begin an interactive introduction to using this app. Sample data, source code and documentation are available at our <a href='https://github.com/alosdiallo/HiC_Network_Viz_tool' target='_blank'>github</a>. <br /><br />Want to analyze more data files simultaneously than this app supports? Just fire up the app in another browser and look at the windows side-by-side! Or download the source code and customize the app to your needs! Hint: the ATAC, ChIP, and mRNA data types actually plot in the same way, so you can plot any bed or bedgraph format data using these options. We are working on allowing the user to define the data type labels themselves, just have not gotten there yet! <br /><br />To exit this help menu click outside the dialog box")),
      footer = actionButton(inputId = "startTutorial","Start Tutorial"),
      easyClose = TRUE
      ))
  })
  
  # Initiate IntroJS tutorial
  observeEvent(input$startTutorial,{
    
    removeModal()
    
    req("HiC" %in% input$fileTypes & "ATAC" %in% input$fileTypes)  
    
    # on click, send custom message to start help
    session$sendCustomMessage(type = 'startHelp', message = list(""))
  })
  
  observeEvent(input$fileTypes, {
    if ("HiC" %in% input$fileTypes){
      shinyjs::show(id = "HiCplot")
      shinyjs::show(id = "HiCNetwork ")
    }
    else{
      shinyjs::hide(id = "HiCplot")
      shinyjs::hide(id = "HiCNetwork ")
      shinyjs::hide(id = "HiCcyclic ")
    }
    if ("ATAC" %in% input$fileTypes){
      shinyjs::show(id = "atacFormatPanelDiv")
      shinyjs::show(id = "ATACPlot")
    }
    else{
      shinyjs::hide(id = "atacFormatPanelDiv")
      shinyjs::hide(id = "ATACPlot")
    }
    if ("ChIP" %in% input$fileTypes){
      shinyjs::show(id = "chipFormatPanelDiv")
      shinyjs::show(id = "ChIPPlot")
    }
    else{
      shinyjs::hide(id = "chipFormatPanelDiv")
      shinyjs::hide(id = "ChIPPlot")
    }
    if ("mRNA" %in% input$fileTypes ){
      shinyjs::show(id = "mrnaFormatPanelDiv")
      shinyjs::show(id = "mRNAPlot ")
    }
    else{
      shinyjs::hide(id = "mrnaFormatPanelDiv")
      shinyjs::hide(id = "mRNAPlot ")
    }
  })
  
  ## Generate dynamic upload UI based on fileTypes selected
  output$dataTabs <- renderUI({
    dataTabs <- lapply(1:length(input$fileTypes), function(i ){
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
    do.call(tabsetPanel, dataTabs)
  })
  #outputOptions(output, "dataTabs", suspendWhenHidden = FALSE) 
  
  ## Render appropriate selection of chromosomes for chosen genome when using the 'Search by Coordinates' option to plot data
  # To add chromosome options for a new species, create a new case for the switch expression
  observeEvent(input$searchby, {
  if (input$searchby == "Coordinates"){ 
    shinyjs::show(id = "searchByCoordinatesDiv")
  output$chromNumberUI <- renderUI({
    switch(input$genome,
           mouse = {
             selectInput(inputId = "chromNumber",
                         label = "Chr Number",
                         choices = c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chrX","chrY"), multiple = FALSE,
                         selectize = TRUE, width = NULL, size = NULL)
           },
           human = {
             selectInput(inputId = "chromNumber",
                         label = "Chr Number",
                         choices = c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY"), multiple = FALSE,
                         selectize = TRUE, width = NULL, size = NULL)
           },
           drosophila_melanogaster = {
             selectInput(inputId = "chromNumber",
                         label = "Chr Number",
                         choices = c("3R","3L","2R","2L","X","Y","4"), multiple = FALSE,
                         selectize = TRUE, width = NULL, size = NULL)
           }
    )
  })
  outputOptions(output, "chromNumberUI", suspendWhenHidden = FALSE) 
  }
    shinyjs::hide(id = "geneIdDiv")
    })
  observeEvent(input$searchby, { 
    if (input$searchby == "Genes"){
      shinyjs::hide(id = "searchByCoordinatesDiv")
      shinyjs::show(id = "geneIdDiv")
      output$searchNamesList <- renderUI({
        switch(input$genome,
               mouse = {
                 selectizeInput(inputId = 'geneId', 
                                label = 'Type gene name: (backspace to clear)', 
                                choices = mousegenes,
                                options = list(maxOptions = 5, placeholder = 'Type gene name', onInitialize = I('function() { this.setValue(""); }'))
                 )
               },
               human = {
                 selectizeInput(inputId = 'geneId', 
                                label = 'Type gene name: (backspace to clear)', 
                                choices = humangenes,
                                options = list(maxOptions = 5, placeholder = 'Type gene name', onInitialize = I('function() { this.setValue(""); }'))
                 )
               },
               drosophila_melanogaster = {
                 selectizeInput(inputId = 'geneId', 
                                label = 'Type gene name: (backspace to clear)', 
                                choices= drosophilagenes,
                                options = list(maxOptions = 5, placeholder = 'Type gene name', onInitialize = I('function() { this.setValue(""); }'))
                 )
               }
        )
      })
    }
  })
 # outputOptions(output, "chromNumberUI", suspendWhenHidden = FALSE) 
  
  ## START OF ANALYSIS/VISUALIZATION BLOCK
  observeEvent(input$processDataBtn,{
    
    # Define submitBy variable
    submitBy <- reactiveValues(method="ByGene")
    
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
        
        #Load geneWindow from user defined parameters if input$submitByCoordinates is invalidated, else load by search coordinates if input$submitByGene is invalidated
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
        
        ntwrk <- graph_from_data_frame(d = edgeData, vertices = nodeData, directed = F)
        
        number_nodes <- vcount(ntwrk)
        if (number_nodes > 30){
          node_size = 6
          node_label = NA
        }else {
          node_size = 18
          node_label = name
        }
  
  
        # NOTE: Reactive variables used as functions networkReactive(). 
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
        }) 
      })
        
        plot(ntwrk, vertex.color = "#CDD1BE", vertex.size =  node_size, edge.width = 1, vertex.label.font = 2, vertex.label = node_label)
        
        output$plotdegree <- renderPlot({ 
          deg <- igraph::degree(ntwrk, mode="all")
          deg.dist <- degree_distribution(ntwrk, cumulative=T, mode="all")
          output$plotdegree = renderPlot({ 
            plot( x=0:max(deg), y=1-deg.dist, pch=19, cex=1.6, col="orange", xlab="Degree", ylab="Cumulative Frequency")
            
            output$downloadPlot_degree <- downloadHandler(
              filename = "Degree_Distribution.png",
              content = function(file) {
                png(file)
                deg <- igraph::degree(ntwrk, mode="all")
                deg.dist <- degree_distribution(ntwrk, cumulative=T, mode="all")
                plot( x=0:max(deg), y=1-deg.dist, pch=19, cex=1.6, col="orange", xlab="Degree", ylab="Cumulative Frequency")
                dev.off()
              }) 
          })
        })
        
        output$plotgroups <- renderPlot({ 
          ceb <- cluster_edge_betweenness(ntwrk)
          plot(ceb, ntwrk, vertex.label = node_label, main = "Community Detection")
          output$membership_data <- renderTable({
            memb_info = membership(ceb)
            Membership = as.character(membership(ceb))
            Node = names(memb_info)
            df = data.frame(Membership, Node)
            print(df)
          #  paste (Membership, Node)
          })
          
          
          output$downloadPlot_groups <- downloadHandler(
            filename = "Community_Detecion.png",
            content = function(file) {
              png(file)
              ceb <- cluster_edge_betweenness(ntwrk)
              plot(ceb, ntwrk, vertex.label = node_label,  main = "Community Detection")
              dev.off()
            }) 
        })
        
        output$plotHubs <- renderPlot({
          hs <- hub_score(ntwrk)$vector
          plot(ntwrk, vertex.size = hs*35, main = "Hubs", vertex.color = "#CDD1BE", edge.width = 1, vertex.label.font = 2, vertex.label = node_label)
          output$downloadPlot_hub <- downloadHandler(
            filename = "Hub.png",
            content = function(file) {
              png(file)
              hs <- hub_score(ntwrk)$vector
              plot(ntwrk, vertex.size = hs*35, main = "Hubs", vertex.color = "#CDD1BE", edge.width = 1, vertex.label.font = 2, vertex.label = node_label)
              dev.off()
            }) 
        })
        
        output$plotNodeDegree <- renderPlot({            
          deg <- igraph::degree(ntwrk, mode = "all")
          dens_deg <- density(x = deg)
          plot(dens_deg, xlab = "Degree", main = "Node Degree Density Plot")
          polygon(dens_deg, col="#DCF7F3", border="#45AAB8")
          #degree_dataframe <- data.frame(deg)
          #hist(x = deg, breaks=1:vcount(ntwrk)-1, main="Histogram of node degree", col = c("#62A9FF"), xlab = "Degree")
          # ggplot(degree_dataframe, aes(x=deg)) + geom_density(color = "darkblue", fill = "skyblue") #+ labs(title =  "Node Degree Density Plot", x = "Degree", y = "Density")
          output$downloadPlot_node_degree <- downloadHandler(
            filename = "Node-Degree.png",
            content = function(file) {
              png(file)
              deg <- igraph::degree(ntwrk, mode = "all")
              dens_deg <- density(x = deg)
              plot(dens_deg, xlab = "Degree", main = "Node Degree Density Plot")
              polygon(dens_deg, col="#DCF7F3", border="#45AAB8")
              # degree_dataframe <- data.frame(deg)
              #hist(deg, breaks=1:vcount(ntwrk)-1, main="Histogram of node degree", col = c("#62A9FF"), xlab  = "Degree")
              #ggplot(degree_dataframe, aes(x=deg)) + geom_density(color = "darkblue", fill = "skyblue") #+ labs(title =  "Node Degree Density Plot", x = "Degree", y = "Density")
              dev.off()
            })
        })
        
        ###### Download Network
        output$downloadNetwork <- downloadHandler(
          filename = function() {
            "Network.png"
          },
          content = function(file) {
            png(file)
            plot(ntwrk, vertex.color = "pink", vertex.size =  node_size, edge.width = 1, vertex.label.font = 2, vertex.label = node_label) 
            dev.off()
          }
        )
        
        ##Download All
        output$downloadAll <- downloadHandler(
          filename = function() {
            "Network-Analysis.pdf"
          },
          content = function(file) {
            pdf(file)
            plot(ntwrk, vertex.color = "pink", vertex.size =  node_size, edge.width = 1, vertex.label.font = 2, vertex.label = node_label)
            hs <- hub_score(ntwrk)$vector
            plot(ntwrk, vertex.size = hs*35, main = "Hubs", vertex.color = "#CDD1BE", edge.width = 1, vertex.label.font = 2, vertex.label = node_label)
            deg <- igraph::degree(ntwrk, mode="all")
            deg.dist <- degree_distribution(ntwrk, cumulative=T, mode="all")
            plot( x=0:max(deg), y=1-deg.dist, pch=19, cex=1.6, col="orange", xlab="Degree", ylab="Cumulative Frequency", main = "Degree Distribution")
            ceb <- cluster_edge_betweenness(ntwrk)
            plot(ceb, ntwrk, vertex.label = node_label, main = "Community Detection")
            #paste0("community membership for each node", membership(ceb))
            deg <- igraph::degree(ntwrk, mode = "all") 
            dens_deg <- density(x = deg)
            plot(dens_deg, xlab = "Degree", main = "Node Degree Density Plot")
            polygon(dens_deg, col="#DCF7F3", border="#45AAB8")
            # degree_dataframe <- data.frame(deg)
            #hist(deg, breaks=1:vcount(ntwrk)-1, main="Histogram of node degree", col = c("#62A9FF"), xlab  = "Degree")
            # ggplot(degree_dataframe, aes(x=deg)) + geom_density(color = "darkblue", fill = "skyblue")# + labs(title =  "Node Degree Density Plot", x = "Degree", y = "Density")
            dev.off()
          }
        )
   
    
    })
 
    
    ###### REACTIVE FUNCTION: Define reactive function to make all plot calls to appropriate outputs. This was made a reactive function to allow multiple "submit" scenarios (ie byGene or byCoordinates)
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
      
      #Load geneWindow from user defined parameters if input$submitByCoordinates is invalidated, else load by search coordinates if input$submitByGene is invalidated
      if( submitBy$method == "ByCoord" ){
        geneWindow <- defineGeneWindowByCoord(input);
      } else if ( submitBy$method == "ByGene" ) {
        geneWindow <- defineGeneWindowByGene(input)
      }
      
      #Load gene annotation data for user defined region
      genes <- readGenes(geneWindow, input)
      
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
      output$cyplot <- renderPlot({
        isolate({ 
          
          #tryCatch error handling for "Error: replacement has 1 row, data has 0", which occurs when the genome window contains no nodes
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
          #tryCatch error handling for "Error: replacement has 1 row, data has 0", which occurs when the genome window contains no nodes
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
    
    ######Execute code to Generate Plots Once Press submitByCoordinates actionButton
    observeEvent(input$submitByCoordinates, {
      submitBy$method = "ByCoord"
      updateTabsetPanel(session = session,inputId = "MainNetwork", selected  = "Network")
      generatePlots()
      
    })
    
    ######Execute code to Generate Plots Once Press submitByGene actionButton
    observeEvent(input$submitByGene, {
      submitBy$method = "ByGene"
      generatePlots()
      
    })
    
    ####### Download Cytoscape Network as PNG (uses cyjs.js script in UI). From https://github.com/cytoscape/r-cytoscape.js/tree/master/inst/examples/shiny
    observeEvent(input$saveImage, {
      # NOTE: Message cannot be an empty string "", nothing will happen    
      session$sendCustomMessage(type="saveImage", message="NULL")
    })
  })
  
  #To enable new-session reconnections, in case the client has disconnected from the server (and has reached a gray-out state)
  session$allowReconnect(TRUE)
 
}
shinyApp(ui = ui, server = server)

