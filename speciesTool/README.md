# Species Gencode Tool

Purpose: To generate appropriate files for adding a new species to the DNARchitect App from gtf file
Output files: 1) species_searchNames.txt == a list of unique gene names with coordinates for the searchByGene function, 2) Gencode.chr*.txt == a Gencode annotation file for each chromosome

## Directions for use
1. Download Species_GenCode_Tool.R and open in R/RStudio
2. Run the code to load the required libraries and create the function speciesTool
3. Set working directory to the directory where you wish all files to be written <br>
`setwd("/Users/user1/Downloads")`
4 Run the speciesTool function specifying the species name and path for the GTF source file <br>
`speciesTool(species="human",gtf_source="/Users/user1/Downloads/human_gencode.gtf")`
