#!/usr/bin/env bash

#This code takes a unix format, tab delimited file of lines 'node1  node2   strength' and generates a JSON object which is written to output.json

echo Please type ./filename and press enter. The file will be converted to JSON format and written as output.json

read filename;

#The input file must be sanitized as follows prior to being fed to this script: Convert to UNIX file format, remove header, add newline to end of last line (if terminal $ does not exist), write to sanitizedFile.txt

#NOTE: using the < after dos2unix sends the output to stdout (instead of editing in place) so it can be piped.
#NOTE: Office 2011 creates MacOS9 CR. Run dos2unix followed by mac2unix to handle both cases.

dos2unix < $filename | mac2unix | tail -n +2 | sed -e '$a\' > sanitizedFile.txt

#Build the JSON object
i=1
json="{"
while read line; do
IFS=$'\t' read -r -a nodearray <<< "${line}";
jsontemplate="\"key\":{\"chrom1\":\"XX1\",\"start1\":\"XX2\",\"end1\":\"XX3\",\"chrom2\":\"XX4\",\"start2\":\"XX5\",\"end2\":\"XX6\",\"name\":\"XX7\",\"score\":\"XX8\",\"FDR\":\"XX9\",\"strand1\":\"YY1\",\"strand2\":\"YY2\",\"samplenumber\":\"YY3\"},";
OUTPUT=$(echo $jsontemplate | sed -e 's/key/'"${i}"'/' -e 's/XX1/'"${nodearray[0]}"'/' -e 's/XX2/'"${nodearray[1]}"'/' -e 's/XX3/'"${nodearray[2]}"'/' -e 's/XX4/'"${nodearray[3]}"'/' -e 's/XX5/'"${nodearray[4]}"'/' -e 's/XX6/'"${nodearray[5]}"'/' -e 's/XX7/'"${nodearray[6]}"'/' -e 's/XX8/'"${nodearray[7]}"'/' -e 's/XX9/'"${nodearray[8]}"'/' -e 's/YY1/'"${nodearray[9]}"'/' -e 's/YY2/'"${nodearray[10]}"'/' -e 's/YY3/'"${nodearray[11]}"'/')
json="$json${OUTPUT}"
((i++));
done < sanitizedFile.txt

#Write JSON object to object.json file. NOTE: output.json has a terminal newline $
#echo $json | sed -e 's/.$//' -e 's/$/}/' > output.json

#If jq is installed do the following instead: write JSON object to object.json file. NOTE: output.json has a terminal newline. Then, beautifying output.json with jq
echo $json | sed -e 's/.$//' -e 's/$/}/' | jq '.' > output.json