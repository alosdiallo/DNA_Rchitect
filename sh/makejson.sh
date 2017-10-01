#!/usr/bin/env bash

#This code takes a unix format, tab delimited file of lines 'node1  node2   strength' and generates a JSON object which is written to output.json

#To time this script us: { time ./makejson_echo.sh ; } 2> time.txt

######This code block is for user defined filename at command line interface
#echo Please type ./filename and press enter. The file will be converted to JSON format and written as output.json
#
#read filename;
######

######This code is for filename given as an argument to script as follows:
## > sh makejson.sh filename.txt
filename=$1
######

#The input file must be sanitized as follows prior to being fed to this script: Convert to UNIX file format, remove header, add newline to end of last line (if terminal $ does not exist), write to sanitizedFile.txt

#NOTE: using the < after dos2unix sends the output to stdout (instead of editing in place) so it can be piped.
#NOTE: Office 2011 creates MacOS9 CR. Run dos2unix followed by mac2unix to handle both cases.

dos2unix < $filename | mac2unix | tail -n +2 | sed -e '$a\' > sanitizedFile.txt

#################
####### MUST UPDATE THIS SCRIPT TO REMOVE OLD OUTPUT.JSON and DATA.JSON FILES DEPENDING ON WHERE THEY END UP BEING STORED IN THE FINAL PRODUCTION
#################
#Delete old json files:
rm output.json data.json ./public/data.json

#Build the JSON object using echo -n. The -n flag specifies no newline ($) so everything is built on one line. Could make it multiple lines
i=1
echo -n "{" >> output.json
while read line; do
IFS=$'\t' read -r -a nodearray <<< "${line}";
jsontemplate="\"Lkey\":{\"node1\":\"XX1:XX2-XX3\",\"node2\":\"XX4:XX5-XX6\",\"name\":\"XX7\",\"score\":\"XX8\",\"FDR\":\"XX9\",\"strand1\":\"YY1\",\"strand2\":\"YY2\",\"samplenumber\":\"YY3\",\"edge\":\"LZZ1\"},";
OUTPUT=$(echo $jsontemplate | sed -e 's/key/'"${i}"'/' -e 's/XX1/'"${nodearray[0]}"'/' -e 's/XX2/'"${nodearray[1]}"'/' -e 's/XX3/'"${nodearray[2]}"'/' -e 's/XX4/'"${nodearray[3]}"'/' -e 's/XX5/'"${nodearray[4]}"'/' -e 's/XX6/'"${nodearray[5]}"'/' -e 's/XX7/'"${nodearray[6]}"'/' -e 's/XX8/'"${nodearray[7]}"'/' -e 's/XX9/'"${nodearray[8]}"'/' -e 's/YY1/'"${nodearray[9]}"'/' -e 's/YY2/'"${nodearray[10]}"'/' -e 's/YY3/'"${nodearray[11]}"'/' -e 's/ZZ1/'"${i}"'/')

echo -n "${OUTPUT}" >> output.json
((i++));
done < sanitizedFile.txt

cat output.json | sed -e '$a\' -e 's/.$//' -e 's/$/}/' > ./public/data.json
