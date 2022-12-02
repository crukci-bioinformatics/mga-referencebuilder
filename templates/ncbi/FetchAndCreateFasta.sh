#!/bin/bash

set -o pipefail

rm -f "!{outputFile}"
count=0

while read url
do
    id=$(basename "$url")
    file=${id}_genomic.fna.gz
    count=$(expr $count + 1)

    echo "${count}    ${id}"

    wget -q -O - "${url}/${file}" | zcat >> "!{outputFile}"
    if [ $? -ne 0 ]
    then
        >&2 echo "Fetch of $file failed."
    fi
done < "!{urlFile}"
