#!/bin/bash

# remove existing metadata file and regenerate
rm metadata.csv

# find all the existing csv subtitle files in the repo (specific to CrewChief)
find . -name "*.csv" | while read A ; do
    # extract the subtitle.csv content into the new file
    PREFIX=$(dirname "$A" | sed 's@./@@')/
    echo "$PREFIX"
    cat "$A" | sed -E 's@^([^,]*),@"'"$PREFIX"'\1",@' >> subtitles.csv
    echo -e "\n" >> subtitles.csv
done

# remove newlines by sort/uniq
sort metadata.csv > tmp.csv
uniq tmp.csv > subtitles.csv

# remove the temp file
rm tmp.csv