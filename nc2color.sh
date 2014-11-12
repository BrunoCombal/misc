#!/bin/bash

indir=$1 #/home/bcombal/ensembleOutput/results
outdir=$2 #/home/bcombal/ensembleOutput/colored
mkdir -p $outdir
tmpdir=$outdir/tmp
mkdir -p $tmpdir
colorMap=color_ramps/NCV_jet_rgb.txt

for ifile in $indir/*.nc
do
    echo "Processing file "$ifile
    thisFile=${ifile##*/}
    tmpfile=${tmpdir}/${thisFile%.nc}_${RANDOM}.tif
    outfile=$outdir/${thisFile%.nc}.tif
    # convert to gtiff
    gdal_translate -of gtiff -co "compress=lzw" -b 1 -scale 273 313 1 255 NETCDF:$indir/$thisFile:mean_mean_thetao $tmpfile
    # apply color scheme
    gdaldem color-relief ${tmpfile} $colorMap $outfile
    rm -f $tmpfile
done


# --- end of script ---