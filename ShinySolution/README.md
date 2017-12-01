Application is available at the following URL:
https://simongray.shinyapps.io/modularApp/

Files for ShinyApps.io solution to run on local server:
hicVizAppBETA.R is legacy (fully functional) code that is not modularized and Data file is read every time submit button invalidates
modHicVizApp1.R is modularized code (stuff is put into functions) so that data is read only once per upload of matrix file. 
***NOTE: USE modHicVizAppBETA.R for any further development
