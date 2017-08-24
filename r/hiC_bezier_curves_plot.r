## General script for 2 sample bezier curve plot with gene features
library(Sushi)

##Command line arguments must be given as: > Rscript Sushi_Long_rangePlots_Rscript.R matrixFileName.txt chrom chromstart chromend samplenumber1_Id samplenumber2_Id samplenumber1_color samplenumber2_color Genecode.chr#.txt
# Example: > Rscript Sushi_Long_rangePlots_Rscript.R H3k_Fox_Hichip_matrix.txt chr1 60853778 60948071 H3K27Ac FoxP3 blue red Gencode.chr1.txt

# arg[1] = matrixFileName.txt 
# arg[2] = chrom 
# arg[3] = chromstart 
# arg[4] = chromend 
# arg[5] = samplenumber1_Id 
# arg[6] = samplenumber2_Id 
# arg[7] = samplenumber1_color 
# arg[8] = samplenumber2_color 
# arg[9] = Genecode.chr#.txt

args <- commandArgs(trailingOnly = TRUE);
data<- read.delim(args[1],header=TRUE);
chrom = args[2];
chromstart = as.numeric(args[3]); #Note that commandArgs makes everything a string, so must convert to numeric
chromend = as.numeric(args[4]);

# Read Ensembl.biomart.chr file to plot gene coordinates (Ensembl.biomart.chr files are available for all mouse genes per chromosome.)
genes <- read.delim(args[9],header=TRUE);

# Open device to write Bezier curves plot and gene-features plot to file
png(filename = "bezierCurve.png")

# Bezier curve plot
par(fig=c(0,1,0.3,1), mar=c(0,4,4,2)); #define area for Bezier curve plot
pbpe = plotBedpe(data,chrom,chromstart,chromend,lwdby = data$score,lwdrange = c(0,2),heights = data$score,plottype="loops",colorby=data$samplenumber,colorbycol=SushiColors(2));
labelgenome(chrom, chromstart,chromend,n=3,scale="Mb");
legend("topleft",inset =0.1,legend=c(args[5],args[6]),col=c(args[7],args[8]),pch=19,bty='n',cex=0.7,text.font=2);
axis(side=2,las=2,tcl=.2);
mtext("Interaction intensity",side=2,line=1.75,cex=.75,font=2);

# Genes features plot
par(fig=c(0,1,0,0.25), mar=c(0,4,0,2), new=TRUE); #This allows genes to be plotted below the BEDPE plot
pg = plotGenes(genes,chrom,chromstart,chromend,types=genes$type,plotgenetype="arrow",maxrows=2,bheight=0.02,bentline=FALSE,labeloffset=0.1,fontsize=0.5,arrowlength = 0.0025,labelat = "middle",labeltext=TRUE,colorby = genes$strand,colorbycol = SushiColors(2));

# Close device
dev.off();
