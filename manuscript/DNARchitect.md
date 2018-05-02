DNARchitect manuscript

Introduction:

Several tools exist for visualizing HiC datasets (Akdemir 2015, Zhou 2013, others?).

Materials and Methods:

We have developed an R package named ‘DNARchitect’ that implements the Shiny R package (Chang 2017) to allow users to interactively visualize genomic data in a web browser. The app is user-friendly and designed for both data analysts and non-bioinformaticians to easily visualize and rapidly browse their own, properly formatted bed, bedgraph, and bedpe datasets. To visualize HiC data, the app implements Sushi (Phanstiel 2015) to generate a plot of bezier curve interaction arcs and rcytoscapejs (Luna) to generate a network diagram from bedpe format data. The app implements Sushi (Phanstiel 2015) to visualize bed or bedgraph format genomic data. DNARchitect accepts comma, semicolon, or tab delimited input files of txt, csv, or bg file format (are there other file formats we should accept?). Users may install and run DNARchitect on their local machine or may access a Shiny app instance that we provide via the web.

DNARchitect has an interactive plotting interface that permits the user to iteratively browse and visualize their data by gene name or specific genomic coordinates (Fig 1). For HiC datasets, the user must specify the number and identification of samples in the uploaded file for appropriate color coding in the bezier curve interaction plot and network diagram. The HiC network diagram is interactive and clicked nodes and their connected neighbors are displayed in an output table. All plots and diagrams generated through the app may be downloaded with a single button click from the web browser. The code for this Shiny app is open-source, available under the MIT license from our Github repository, and may be modified by a developer to incorporate other plots types at their discretion.

Word count: 274

Usage scenario:


Figure 1:
a)	Screen shot of the Upload File panel with appropriately formatted usage case data uploaded
b)	Screen shot of the Plot panel with usage case data plotted

References:

Akdemir, K. C. & Chin, L. 2015. HiCPlotter integrates genomic data with interaction matrices. Genome Biology, 16, 198.

Chang W., Cheng J., Allaire J.J., Xie Y., and McPherson J. (2017). shiny: Web Application Framework for R. R package version 1.0.5. https://CRAN.R-project.org/package=shiny

Luna, A (NA). rcytoscapejs: Cytoscape JS HTMLWidgets. R package version 0.0.7.

Phanstiel DH (2015). Sushi: Tools for visualizing genomics data. R package version 1.18.0.

Zhou, X., Lowdon, R. F., Li, D., Lawson, H. A., Madden, P. a. F., Costello, J. F. & Wang, T. 2013. Exploring long-range genome interactions using the WashU Epigenome Browser. Nature Methods, 10, 375.
