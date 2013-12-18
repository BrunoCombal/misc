#!/bin/bash

#\author Bruno Combal, IOC-UNESCO
#\date December 2013

# resample population projections to match ACE2 grid (9 arc second)
# tested with gdal 1.9.2

# ACE2 9 arc second is described in:
# http://tethys.eaprs.cse.dmu.ac.uk/ACE2/docs/README_9sec_heights.txt

# gdalwarp has the following options:
# -wm: memory to be used for resampling
# output format: GeoTiff (bigtiff, >4GB), with internal compression (lzw), tiled (256x256) and sparse (combined with tiled, nothing written for empty tiles)
# -multi: Use multithreaded warping implementation. Multiple threads will be used to process chunks of image and perform input/output operation simultaneously.

infile=pop2100_est.tif
outfile=pop2100_est_ACE29S.tif

resampling='bilinear'
tr=$(echo "scale=12; 0.15/60" | bc)
xmin=-180
xmax=180
ymin=-90
ymax=90

gdalwarp -overwrite -tr $tr $tr -r $resampling -te $xmin $ymin $xmax $ymax -wm 20 -multi -of GTIFF -co "compress=LZW" -co "BIGTIFF=YES" -co "tiled=YES" -co "sparse_ok=TRUE" $infile $outfile

# end of script
