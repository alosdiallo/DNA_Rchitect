# Species Gencode Tool
# Purpose: To generate appropriate files for adding a new species to the DNARchitect 
# App from gtf file
# Output files: 1) species_searchNames.txt == a list of unique gene names with 
# coordinates for the searchByGene function, 2) Gencode.chr*.txt == a Gencode 
# annotation file for each chromosome

### WHERE TO GET GTF FILES:
# You can get gtf files from ensEMBLE.org from the following ftp
# ftp://ftp.ensembl.org/../pub/release-92/gtf/
# Just find the directory with your species and download the gtf

### Load required library packages
library(data.table) #For data.table functions
library(dplyr) #Load dplyr for filter function
library(stringr) #For str_extract function

### FUNCTION: Define speciesTool function to generate searchNames.txt and 
# Gencode.chr*.txt files. Required inputs are species="speciesNameHere"
# and gtf_source="pathToGtfFileHere"
speciesTool <- function(species="human",gtf_source="human_gencode.gtf"){
  
  #####################
  #####################
  # Code to read and parse gtf file 
  #####################
  #####################
  
  # required packages for this code are data.table and stringr
  
  # read the species gtf file, use fread due to files large size
  gtfData <- fread(gtf_source);
  
  print(paste0(gtf_source," has been read, processing may take a few minutes...",sep=""));
  
  # add header to gtfData
  colnames(gtfData) <- c("chrom","source","feature","start","stop","score","strand","frame","attribute");
  
  # extract rows with feautre == gene
  gtfGenes <- gtfData[gtfData$feature == "gene",];
  
  # change + to +1 and - to -1 in strand.
  gtfGenes <- within(gtfGenes, strand[strand == "+"] <- "+1");
  gtfGenes <- within(gtfGenes, strand[strand == "-"] <- "-1");
  
  # add a column for $name2 by duplicating the $score column and extract gene name from $attribute
  gtfGenes$name2 <- gtfGenes$score;
  gtfGenes <- within(gtfGenes, name2 <- gsub(".*gene_name \"|\".*", "", attribute));
  gtfGenes <- gtfGenes[, c("source","feature","frame","attribute"):=NULL];
  
  #####################
  #####################
  # Code to generate list of all unique gene names with their coordinates from gencode 
  # data for the search function in DNARchitect and export as .txt file
  #####################
  #####################
  
  ## Required packages for this code are are data.table and dplyr
  
  AllGenesDT <- NULL;
  AllGenesDT <- data.table(gtfGenes);
  UniqueNames <- NULL;
  UniqueNames <- unique(AllGenesDT$name2);
  
  geneDuplicates <- NULL;
  searchNames <- NULL;
  searchID <- NULL;
  for(i in 1:length(UniqueNames)){
    geneDuplicates <- filter(AllGenesDT, name2 == UniqueNames[i]);
    searchID <- paste(UniqueNames[i], unique(geneDuplicates$chrom), sep=" ");
    searchID <- paste(searchID, min(geneDuplicates$start), sep=":");
    searchID <- paste(searchID, max(geneDuplicates$stop), sep="-");
    searchNames[i] <- searchID;
  }
  
  # Export file of species_searchNames as .txt file
  write(searchNames, paste0(species,"_searchNames.txt",sep=""), sep="\t");
  print(paste0(species,"_searchNames.txt file written to working directory",sep=""));
  
  
  #####################
  #####################
  # Code to generate and export Gencode.chr*.txt file for each chromosome
  #####################
  #####################
  
  chr_num <- unique(gtfGenes$chrom);
  
  Gencode_tmp <- NULL;
  for(i in 1:length(chr_num)){
    Gencode_tmp <- gtfGenes[gtfGenes$chrom == chr_num[i],];
    write.table(Gencode_tmp, file = paste0("Gencode.",chr_num[i],".txt",sep=""), row.names=FALSE, quote = FALSE, sep="\t");
    print(paste0("Gencode.",chr_num[i],".txt file written to working directory",sep=""));
  } 
  
}


#####################
#####################
#Using the speciesTool function:

#1 Download gtf file from ensEMBL: ftp://ftp.ensembl.org/../pub/release-92/gtf/

#2 Run the above code to load the required libraries and create the function speciesTool

#3 set working directory to the directory where you wish all files to be written
setwd("/Users/user1/Downloads")

#4 run the speciesTool function specifying the species name and path for the GTF source file
speciesTool(species="human",gtf_source="/Users/user1/Downloads/human_gencode.gtf")
