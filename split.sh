#!/bin/bash

#\author Bruno Combal, IOC-UNESCO
#\date December 2013

# split a large file in smaller ones

if [ $# -ne 2 ]; then
    echo "Wrong number of input parameters. Exit(1)."
    exit 1
fi

inputFile=$1
outputDir=$2

if [ ! -e "$inputFile" ]; then
    echo "Input file ${inputFile} not found. Exit(2)."
    exit 2
fi

if [ ! -d "$outputDir" ]; then 
    echo "Output directory ${outputDir} not found. Exit(3)"
    exit 3
fi

# get input file dimensions
dims=($(gdalinfo -nogcp -nomd -norat -noct -nofl $inputFile | grep 'Size is' | sed 's/Size is//' | sed 's/,/ /'))

echo "Initial dimensions" ${dims[@]}
xstep=$((dims[0]/4))
ystep=$((dims[1]/4))
echo "xstep=$xstep and ystep=$ystep"

bnFile=${inputFile##*/}
baseName=${bnFile%.*}

for ((ii=0; ii<${dims[0]}; ii+=$xstep))
do
    for ((jj=0; jj<${dims[1]}; jj+=$ystep))
    do
	gdal_translate -of 'gtiff' -co 'compress=lzw' -co "bigtiff=IF_NEEDED" -srcwin $ii $jj $((ii + xstep)) $((jj + ystep)) $inputFile $outputDir/${baseName}_${ii}_${jj}.tif
    done
done

# end of script