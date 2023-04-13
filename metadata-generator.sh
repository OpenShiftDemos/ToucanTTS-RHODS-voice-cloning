#!/bin/bash

# remove existing metadata file and regenerate
rm metadata.csv

# find all the existing csv subtitle files in the repo (specific to CrewChief)
find . -name "*.csv" | while read A ; do
    # extract the subtitle.csv content into the new file
    PREFIX=$(dirname "$A" | sed 's@./@@')/
    #echo "$PREFIX"
    cat "$A" | sed -E 's@^([^,]*),@'"$PREFIX"'\1|@' >> metadata.csv
    echo -e "\n" >> metadata.csv
done

# remove the .wav extensions to meet ljspeech style
sed -i 's/\.wav//' metadata.csv

# remove the quotation marks originally present in the subtitle.csv
sed -i 's/"//g' metadata.csv

# remove blank lines
sed -i '/^\s*$/d' metadata.csv