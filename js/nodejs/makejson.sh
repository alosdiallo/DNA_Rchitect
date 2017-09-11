#!/usr/bin/env bash

#This code takes a unix format, tab delimited file of lines 'node1  node2   strength' and generates a JSON object which is written to output.json

#To time this script us: { time ./makejson_echo.sh ; } 2> time.txt

#######This code block is for user defined filename at command line interface
#echo Please type ./filename and press enter. The file will be converted to JSON format and written as output.json
#
#read filename;
#######

#####This code is for filename given as an argument to script as follows:
# > sh makejson.sh filename.txt
filename=$1
#####

#The input file must be sanitized as follows prior to being fed to this script: Convert to UNIX file format, remove header, add newline to end of last line (if terminal $ does not exist), write to sanitizedFile.txt

#NOTE: using the < after dos2unix sends the output to stdout (instead of editing in place) so it can be piped.
#NOTE: Office 2011 creates MacOS9 CR. Run dos2unix followed by mac2unix to handle both cases.

dos2unix < $filename | mac2unix | tail -n +2 | sed -e '$a\' > sanitizedFile.txt

#Build the JSON object using echo -n. The -n flag specifies no newline ($) so everything is built on one line. Could make it multiple lines
i=1
echo -n "{" >> output.json
while read line; do
IFS=$'\t' read -r -a nodearray <<< "${line}";
jsontemplate="\"key\":{\"chrom1\":\"XX1\",\"start1\":\"XX2\",\"end1\":\"XX3\",\"chrom2\":\"XX4\",\"start2\":\"XX5\",\"end2\":\"XX6\",\"name\":\"XX7\",\"score\":\"XX8\",\"FDR\":\"XX9\",\"strand1\":\"YY1\",\"strand2\":\"YY2\",\"samplenumber\":\"YY3\"},";
OUTPUT=$(echo $jsontemplate | sed -e 's/key/'"${i}"'/' -e 's/XX1/'"${nodearray[0]}"'/' -e 's/XX2/'"${nodearray[1]}"'/' -e 's/XX3/'"${nodearray[2]}"'/' -e 's/XX4/'"${nodearray[3]}"'/' -e 's/XX5/'"${nodearray[4]}"'/' -e 's/XX6/'"${nodearray[5]}"'/' -e 's/XX7/'"${nodearray[6]}"'/' -e 's/XX8/'"${nodearray[7]}"'/' -e 's/XX9/'"${nodearray[8]}"'/' -e 's/YY1/'"${nodearray[9]}"'/' -e 's/YY2/'"${nodearray[10]}"'/' -e 's/YY3/'"${nodearray[11]}"'/')

echo -n "${OUTPUT}" >> output.json
((i++));
done < sanitizedFile.txt

cat output.json | sed -e '$a\' -e 's/.$//' -e 's/$/}/' > output2.json

#JSON can be 'beautified' using jq as follows: jq '.' > output3.json
