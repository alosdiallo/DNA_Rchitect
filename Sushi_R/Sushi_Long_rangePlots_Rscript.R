##test example with these coordinates
##Produces all interactions from both datasets
##Code_1
# library(Sushi)
# data<- read.delim("H3k_Fox_Hichip_matrix.txt",header=TRUE)
# chrom = "chr1"
# chromstart = 60853778
# chromend = 60948071
# pbpe = plotBedpe(data,chrom,chromstart,chromend,heights = data$score,plottype="loops")
# labelgenome(chrom, chromstart,chromend,n=3,scale="Mb")
# legend("topleft",inset =0.1,legend=c("All interactions"),
# col="black",pch=19,bty='n',text.font=2,cex=0.7)
# axis(side=2,las=2,tcl=.2)
# mtext("Interaction intensity",side=2,line=1.75,cex=.75,font=2)


## Two data sets
## This is for coloring on both datasets H3k27ac and Foxp3. Scale may need to be adjusted for Mb or Kb.
##Code2
data<- read.delim("H3k_Fox_Hichip_matrix.txt",header=TRUE)
chrom = "chr1"
chromstart = 60853778
chromend = 60948071
par(fig=c(0,1,0.3,1), mar=c(0,4,4,2)) #define area for Bezier curve plot
pbpe = plotBedpe(data,chrom,chromstart,chromend,lwdby = data$score,lwdrange = c(0,2),heights = data$score,plottype="loops",colorby=data$samplenumber,colorbycol=SushiColors(2))
labelgenome(chrom, chromstart,chromend,n=3,scale="Mb")
legend("topleft",inset =0.1,legend=c("H3K27Ac","FoxP3"),col=c("blue","red"),pch=19,bty='n',cex=0.7,text.font=2)
axis(side=2,las=2,tcl=.2)
mtext("Interaction intensity",side=2,line=1.75,cex=.75,font=2)

## plot genes for given coordinates. Ensembl.biomart.chr files are available for all mouse genes per chromosome.
##Code3
# chrom = "chr1"
# chromstart = 60853778
# chromend = 60948071
par(fig=c(0,1,0,0.25), mar=c(0,4,0,2), new=TRUE) #This allows genes to be plotted over BEDPE plot
genes <- read.delim("Gencode.chr1.txt",header=TRUE)
pg = plotGenes(genes,chrom,chromstart,chromend,types=genes$type,plotgenetype="arrow",maxrows=2,bheight=0.02,bentline=FALSE,labeloffset=0.1,fontsize=0.5,arrowlength = 0.0025,labelat = "middle",labeltext=TRUE,colorby = genes$strand,colorbycol = SushiColors(2))
# labelgenome( chrom, chromstart,chromend,n=3,scale="Mb",side=3)
