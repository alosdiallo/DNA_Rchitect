library(shiny)
# Load rcytoscapejs
library(rcytoscapejs)
#Load sushi
library(Sushi)
#Load DataTables
library(DT)

#Set maximum upload size to 30 mb
options(shiny.maxRequestSize = 30*1024^2)

# UI for Shiny
ui <- fluidPage(title = "HiC Visualization App",
                tags$h1("HiC Visualization App"),
                tabsetPanel(              
                  tabPanel(title = "Upload File",
                           # App title ----
                           titlePanel("Uploading Files"),
                           
                           # Sidebar layout with input and output definitions ----
                           sidebarLayout(
                             
                             # Sidebar panel for inputs ----
                             sidebarPanel(
                               
                               # Input: Select a file ----
                               fileInput("file1", "Choose a TXT or CSV File",
                                         multiple = TRUE,
                                         accept = c(".txt","text/csv",
                                                    "text/comma-separated-values,text/plain",
                                                    ".csv")),
                               
                               # Horizontal line ----
                               tags$hr(),
                               
                               # Input: Checkbox if file has header ----
                               checkboxInput("header", "Header", TRUE),
                               
                               # Input: Select separator ----
                               radioButtons("sep", "Separator",
                                            choices = c(Comma = ",",
                                                        Semicolon = ";",
                                                        Tab = "\t"),
                                            selected = "\t"),
                               
                               # Input: Select quotes ----
                               radioButtons("quote", "Quote",
                                            choices = c(None = "",
                                                        "Double Quote" = '"',
                                                        "Single Quote" = "'"),
                                            selected = '"'),
                               
                               # Horizontal line ----
                               tags$hr(),
                               
                               # Input: Select number of rows to display ----
                               radioButtons("disp", "Display",
                                            choices = c(Head = "head",
                                                        Tail = "tail"),
                                            selected = "head")
                               
                             ),
                             
                             # Main panel for displaying outputs ----
                             mainPanel(
                               
                               # Output: Data file ----
                               tableOutput("contents")
                               
                             )
                             
                           )
                  ),
                  tabPanel(title = "Plots",
                           fluidRow(tags$br()),
                           fluidRow(
                             column(3,
                                    selectInput(inputId = "chromNumber", 
                                                label = "Chr Number",
                                                choices = c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chrX","chrY"), multiple = FALSE,
                                                selectize = TRUE, width = NULL, size = NULL),
                                    actionButton("submit", "Submit Parameters")
                             ),
                             column(3,
                                    textInput(inputId = "cStart", 
                                              label = "Start coordinate",
                                              value = "60853778"),
                                    textInput(inputId = "cStop", 
                                              label = "End coordinate",
                                              value = "60948071")
                             ),
                             column(3,
                                    textInput(inputId = "sNumber1", 
                                              label = "Sample 1 ID",
                                              value = "H3K27Ac"),
                                    textInput(inputId = "sNumber2", 
                                              label = "Sample 2 ID",
                                              value = "FoxP3")
                             ),
                             column(3,
                                    selectInput(inputId = "sColor1", 
                                                label = "Sample 1 Color",
                                                choices = c("blue","red"), multiple = FALSE,
                                                selectize = TRUE, width = NULL, size = NULL),
                                    selectInput(inputId = "sColor2", 
                                                label = "Sample 2 Color",
                                                choices = c("red","blue"), multiple = FALSE,
                                                selectize = TRUE, width = NULL, size = NULL)
                             )
                           ),
                           fluidRow(tags$hr()),
                           fluidRow(
                             column(6,
                                    wellPanel(
                                      downloadButton("downloadDataBezier", "Download Plot"),
                                      tags$hr(),
                                      plotOutput("bezierplot")
                                    )
                             ),
                             column(6,
                                    wellPanel(
                                      actionButton("saveImage", "Download as PNG"),
                                      tags$hr(),
                                      rcytoscapejsOutput("cyplot", height="400px")
                                    )
                             )
                           ),
                           fluidRow(tags$hr()),
                           fluidRow(
                             column(12,
                                    wellPanel(
                                      h4("Clicked Node"),
                                      verbatimTextOutput("clickedNode"),
                                      h4("Connected Nodes"),
                                      verbatimTextOutput("connectedNodes")
                                    )
                                    )
                           )
                           # ,
                           # fluidRow(tags$hr()),
                           # fluidRow(
                           #   h4("Selected Node Data"),
                           #   dataTableOutput("nodeDataTable")
                           # ),
                           # fluidRow(
                           #   h4("Selected Edge Data"),
                           #   dataTableOutput("edgeDataTable")
                           # )
                  )
                ),
                
                # Call javavscript cyjs.js in www folder to download Cytoscape network as PNG. From: https://github.com/cytoscape/r-cytoscape.js/tree/master/inst/examples/shiny
                tags$head(tags$script(src="cyjs.js"))
)

# Server for Shiny
server <- function(input, output, session) {

  # Define reactive expression to read uploaded file, only after it has been uploaded
  reqRead <- reactive({
    
    #Wait until input$file1 exists before proceeding...
    req(input$file1)
    
    data <- read.delim(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
    
    return(data)
  })
  
  #####
  #Define function to plot bezier curves
  plotBezierCurves <- reactive({
    
    withProgress(message = 'Making bezier curve plot', value = 0, {
      
      #Increment progress
      incProgress(0.6)
      
      # Call reactive expression to store upload file contents in variable: data
      data <- reqRead()
      
      #Make column for bezier curve color (beziercolor). Change value of beziercolor based on conditional: if input$sColor1 =="blue", then color 1 (Sushi colors 1 is blue), else color 2 (Sushi colors 2 is blue)
      data$bezierColor <- data$samplenumber
      data <- within(data, bezierColor[samplenumber == 1] <- if(input$sColor1 =="blue"){1}else{2})
      data <- within(data, bezierColor[samplenumber == 2] <- if(input$sColor2 =="blue"){1}else{2})
      
      chrom = input$chromNumber;
      chromstart = as.numeric(input$cStart); #Note that commandArgs makes everything a string, so must convert to numeric
      chromend = as.numeric(input$cStop);
      
      # Read Ensembl.biomart.chr file from googleStorage public URL to plot gene coordinates (Ensembl.biomart.chr files are available for all mouse genes per chromosome.)
      geneCChNumber_generic = "https://storage.googleapis.com/gencode_ch_data/";
      genCode <- paste(geneCChNumber_generic,"Gencode.",chrom,".txt",sep = "")
      genes <- read.delim(genCode,header=TRUE);
      
      # Bezier curve plot; note: colorby=data$bezierColor in order to allow user to change color scheme reactively
      par(fig=c(0,1,0.3,1), mar=c(0,4,4,2)); #define area for Bezier curve plot
      pbpe = plotBedpe(data,chrom,chromstart,chromend,lwdby = data$score,lwdrange = c(0,2),heights = data$score,plottype="loops",colorby=data$bezierColor,colorbycol=SushiColors(2));
      labelgenome(chrom, chromstart,chromend,n=3,scale="Mb");
      legend("topleft",inset =0.1,legend=c(input$sNumber1,input$sNumber2),col=c(input$sColor1,input$sColor2),pch=19,bty='n',cex=0.7,text.font=2);
      axis(side=2,las=2,tcl=.2);
      mtext("Interaction intensity",side=2,line=1.75,cex=.75,font=2);
      
      # Genes features plot
      par(fig=c(0,1,0,0.25), mar=c(0,4,0,2), new=TRUE); #This allows genes to be plotted below the BEDPE plot
      pg = plotGenes(genes,chrom,chromstart,chromend,types=genes$type,plotgenetype="arrow",maxrows=2,bheight=0.02,bentline=FALSE,labeloffset=0.1,fontsize=0.5,arrowlength = 0.0025,labelat = "middle",labeltext=TRUE,colorby = genes$strand,colorbycol = SushiColors(2))
      
      #Increment progress
      incProgress(0.8)
    })
    
  })
  
  #####
  #Define function to print bezier curves
  printBezierCurves <- reactive({
    # Call reactive expression to store upload file contents in variable: data
    data <- reqRead()
    
    #Make column for bezier curve color (beziercolor). Change value of beziercolor based on conditional: if input$sColor1 =="blue", then color 1 (Sushi colors 1 is blue), else color 2 (Sushi colors 2 is blue)
    data$bezierColor <- data$samplenumber
    data <- within(data, bezierColor[samplenumber == 1] <- if(input$sColor1 =="blue"){1}else{2})
    data <- within(data, bezierColor[samplenumber == 2] <- if(input$sColor2 =="blue"){1}else{2})
    
    chrom = input$chromNumber;
    chromstart = as.numeric(input$cStart); #Note that commandArgs makes everything a string, so must convert to numeric
    chromend = as.numeric(input$cStop);
    
    # Read Ensembl.biomart.chr file from googleStorage public URL to plot gene coordinates (Ensembl.biomart.chr files are available for all mouse genes per chromosome.)
    geneCChNumber_generic = "https://storage.googleapis.com/gencode_ch_data/";
    genCode <- paste(geneCChNumber_generic,"Gencode.",chrom,".txt",sep = "")
    genes <- read.delim(genCode,header=TRUE);
    
    # Bezier curve plot
    par(fig=c(0,1,0.3,1), mar=c(0,4,4,2)); #define area for Bezier curve plot
    pbpe = plotBedpe(data,chrom,chromstart,chromend,lwdby = data$score,lwdrange = c(0,2),heights = data$score,plottype="loops",colorby=data$bezierColor,colorbycol=SushiColors(2));
    labelgenome(chrom, chromstart,chromend,n=3,scale="Mb");
    legend("topleft",inset =0.1,legend=c(input$sNumber1,input$sNumber2),col=c(input$sColor1,input$sColor2),pch=19,bty='n',cex=0.7,text.font=2);
    axis(side=2,las=2,tcl=.2);
    mtext("Interaction intensity",side=2,line=1.75,cex=.75,font=2);
    
    # Genes features plot
    par(fig=c(0,1,0,0.25), mar=c(0,4,0,2), new=TRUE); #This allows genes to be plotted below the BEDPE plot
    pg = plotGenes(genes,chrom,chromstart,chromend,types=genes$type,plotgenetype="arrow",maxrows=2,bheight=0.02,bentline=FALSE,labeloffset=0.1,fontsize=0.5,arrowlength = 0.0025,labelat = "middle",labeltext=TRUE,colorby = genes$strand,colorbycol = SushiColors(2))
  })
  
  ##### Define function to plot cytoscape network
  plotCyNetwork <- reactive({
    
    withProgress(message = 'Making cytoscape plot', value = 0, {
      
      # Call reactive expression to store upload file contents in variable: data
      data <- reqRead()
      
      chrom = input$chromNumber;
      cStart = as.numeric(input$cStart);
      cStop = as.numeric(input$cStop);
      
      #Trim data by chrom, cStart, and cStop
      trimmedData <- data[which(data$chrom1 == chrom),]
      trimmedData <- trimmedData[which(trimmedData$start1 > cStart),]
      trimmedData <- trimmedData[which(trimmedData$end1 < cStop),]
      trimmedData <- trimmedData[which(trimmedData$start2 > cStart),]
      trimmedData <- trimmedData[which(trimmedData$end2 < cStop),]
      
      # Update data to equal trimmedData
      data <- trimmedData
      
      # Convert user defined color to Hex color. #0000FF is blue; #FF0000 is red
      color1 <- if(input$sColor1 =="blue"){"#0000FF"}else{"#FF0000"}
      color2 <- if(input$sColor2 =="blue"){"#0000FF"}else{"#FF0000"}
      
      #Make column for color and change color based on samplenumber;
      data$color <- data$samplenumber
      data <- within(data, color[samplenumber == 1] <- color1)
      data <- within(data, color[samplenumber == 2] <- color2)
      
      #Define node1
      data$node1 <- paste(data$chrom1,":",data$start1,"-",data$end1, sep = "")
      #Define node2
      data$node2 <- paste(data$chrom2,":",data$start2,"-",data$end2, sep = "")
      #Define unique nodes (by appending node1 and node2)
      nodes <- unique(append(data$node1,data$node2))
      
      id <- nodes
      name <- id
      nodeData <- data.frame(id, name, stringsAsFactors=FALSE)
      
      source <- data$node1
      target <- data$node2
      edgeData <- data.frame(source, target, stringsAsFactors=FALSE)
      edgeData$color <- data$color
      
      ## Code for displaying reactive network of selected node with connected nodes
      # Define network that will be used for displaying connected nodes as = edgeData
      network <- edgeData
      
      # NOTE: Reactive variables used as functions networkReactive(). Code block taken verbatim from: https://github.com/cytoscape/r-cytoscape.js/tree/master/inst/examples/shiny
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
  
  ###### File Upload Server Side
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects and uploads a file, head of that data file by default, or tail if selected, will be shown
    
    # Wait until input$file1 exists before proceeding...
    req(input$file1)
    
    # Call reactive expression to store upload file contents in variable: data
    data <- reqRead()
    
    if(input$disp == "head") {
      return(head(data))
    }
    else {
      return(tail(data))
    }
    
  })
  ######
  
  ######Execute code to Update Plots Once Press Submit actionButton
  observeEvent(input$submit, {
    
    #Wait until input$file1 exists before proceeding...
    req(input$file1)
    
    ####### Cytoscape Network Output:
    output$cyplot <- renderRcytoscapejs({
      isolate({ plotCyNetwork() })
      })
    
    ######## Bezier Curve Plot Output:
    output$bezierplot <- renderPlot({
      isolate({ plotBezierCurves() })
    })
    
    output$downloadDataBezier <- downloadHandler(
      filename = function() {
        "bezier_plot.svg"
      },
      content = function(file) {
        svg(file)
        printBezierCurves()
        dev.off()
      }
    )
    
    ########

  })
  ########
  
  ####### Download Cytoscape Network as PNG (uses cyjs.js script in UI). From https://github.com/cytoscape/r-cytoscape.js/tree/master/inst/examples/shiny
  observeEvent(input$saveImage, {
    # NOTE: Message cannot be an empty string "", nothing will happen    
    session$sendCustomMessage(type="saveImage", message="NULL")
  })

}


shinyApp(server = server, ui = ui)