#!/usr/bin/env bash

#This code takes a unix format, tab delimited file of lines 'node1  node2   strength' and generates a JSON object which is written to output.json

echo Please type ./filename and press enter. The file will be converted to JSON format and written as output.json

read filename;

#The input file must be sanitized as follows prior to being fed to this script: Convert to UNIX file format, remove header, add newline to end of last line (if terminal $ does not exist), write to sanitizedFile.txt

dos2unix < $filename | tail -n +2 | sed -e '$a\' > sanitizedFile.txt

#Build the JSON object
i=1
json="{"
while read line; do
IFS=$'\t' read -r -a nodearray <<< "${line}";
jsontemplate="\"key\":{\"node1\":\"n1\",\"node2\":\"n2\",\"strength\":\"X\"},";
OUTPUT=$(echo $jsontemplate | sed -e 's/key/'"${i}"'/' -e 's/n1/'"${nodearray[0]}"'/' -e 's/n2/'"${nodearray[1]}"'/' -e 's/X/'"${nodearray[2]}"'/')
json="$json${OUTPUT}"
((i++));
done < sanitizedFile.txt

#Write JSON object to object.json file. NOTE: output.json has a terminal newline $
echo $json | sed -e 's/.$//' -e 's/$/}/' > output.json

#If jq is installed do the following instead: write JSON object to object.json file. NOTE: output.json has a terminal newline. Then, beautifying output.json with jq
#echo $json | sed -e 's/.$//' -e 's/$/}/' | jq '.' > output.json
