# Species Gencode Tool: speciesTool

Purpose: To generate appropriate files for adding a new species to the DNARchitect App from a raw gtf file <br>

Output files: <br>
1) species_searchNames.txt == a list of unique gene names with coordinates for the searchByGene function <br>
2) Gencode.chr*.txt == a Gencode annotation file for each chromosome where chr* indicates any chromosome in the gtf

## Directions for use
1. Download gtf file for your species of interest. GTF files can be found at [ensEMBL](http://www.ensembl.org) (release-92 FTP from ftp://ftp.ensembl.org/../pub/release-92/gtf/) or the [UCSC genome browser](http://hgdownload.soe.ucsc.edu/downloads.html), among other repositories. Note that the gtf file will need to be unzipped and saved in your working directory after download from the repository.
2. Download Species_GenCode_Tool.R file and in the RStudio program
3. Run the code between the #*** and #*** to load the required libraries and create the function `speciesTool`
4. Set working directory to the directory where you wish all files to be written <br>
For example, if your files are in the `/Users/user1/Downloads` directory, the code would be as follows: <br>
`setwd("/Users/user1/Downloads")` !!! NOTE: This is example code, you must modify it for your situation <br>
5. Run the speciesTool function in RStudio, specifying the species name and path for the GTF source file <br>
For example, if you have a human gtf file at `/Users/user1/Downloads/human_gencode.gtf` path, the code would be as follows: <br>
`speciesTool(species="human",gtf_source="/Users/user1/Downloads/human_gencode.gtf")` !!! NOTE: This is example code, you must modify it for your situation <br>
6. The files that are generated will be written to the working directory
