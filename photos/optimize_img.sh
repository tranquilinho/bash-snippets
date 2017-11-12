#!/bin/bash


readonly input=$1
readonly file=$(basename "${input}")
extension="${file##*.}"
extension=${extension,,}
readonly output_extension=$2
readonly name="${file%%.*}"
readonly orig=${name}_orig.${extension}
readonly output=${name}.${output_extension}

mv ${file} ${orig}

if [ ${extension} == "png" ]; then
    # https://developers.google.com/speed/docs/insights/OptimizeImages
    # PNG -> Remove alpha
    convert ${orig} -strip -background white -alpha remove -alpha off -flatten ${output}
elif [ ${extension} == "jpg" ]; then 
    # JPG: quality <= 85%, reduced chroma sampling, progresive compression
    convert ${orig} -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB ${output}
else
    echo "Unknow image extension"
fi
