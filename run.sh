#!/bin/bash

# \author: Bruno Combal, IOC/UNESCO
# \date: 2013, December

# provides examples showing how to use others scripts

# convert netcdf to colored gtiff
function ncToColor(){
    indir='/Users/bruno/Desktop/t2/results'
    outdir='/Users/bruno/Desktop/t2/colored/'
    mkdir -p ${outdir}
    tmpdir=${outdir}/tmp
    mkdir -p ${tmpdir}
    nodata=100000000000000000000

    for ii in ${indir}/*.nc
    do
	thisFile=${ii##*/}
	./ncToGtiff.sh -s '273 313 1 255' -c color_ramps/NCV_jet.rgb -o ${outdir}/${thisFile%.nc}.tif -n $nodata -d mean_mean_thetao -w ${tmpdir} ${indir}/${thisFile}
	echo ./ncToGtiff.sh -c /Users/bruno/Documents/github/misc/color_ramps/NCV_jet.rgb -o ${outdir}/${thisFile%.nc}.tif -n $nodata -d mean_mean_thetao -w ${tmpdir} ${indir}/${thisFile}
    done
}

# export DHM datasets
function do_dhm(){
    rcp='rcp45'
    
    indir='/data/tmp/new_algo/dhm_rcp'${rcp}'/'
    outdir=/data/tmp/new_algo/export_tif
    maskSHP=/data/tmp/new_algo/landMask.shp
    mkdir -p $outdir
    tmpdir=$outdir/tmp
    mkdir -p $tmpdir
    
    
    for decade in 2010 2020
    do
	nodata=-1
	echo 'frequency: nc to gtiff'
	./ncToGTiff.sh -o ${outdir}/frequency_lvl2_${decade}_${rcp}.tif  -n $nodata -m ${maskSHP} -d lvl2_freq -w ${tmpdir} ${indir}/frequency_lvl2_${decade}.nc 
	
#    echo "dhm: nc to gtiff"
    # gdalrasterize does not understand 1.e20
#    nodata=100000000000000000000
#    decadeEnd=$((decade+10))
#    ./ncToGTiff.sh -w ${tmpdir} -o ${outdir}/dhm_decade_${decade}_${rcp}.tif -n $nodata -d dhm -w tmp -m ${maskSHP} -p ${indir} `for ((ii=${decade}; ii<${decadeEnd}; ii++)); do echo dhm_${ii}.nc; done`
	
    done
}

# export warmpools datasets
# $1: rcp
function do_wp(){
    maskSHP=/data/tmp/new_algo/landMask.shp
    if [ "$1" = 'rcp45' ]; then
	indir='/data/cmip5/rcp/rcp4.5/tos_warmpools/'
	outdir='/data/tmp/temp/export/rcp45/tos_warmpools/'
	tmpdir=${outdir}/tmp
	outname='warmpool_rcp45'
    else
	echo "missing rcp parameter"
	exit
    fi
    mkdir -p ${outdir}
    mkdir -p ${tmpdir}
    for ifile in ${indir}/warmpool_*.nc
    do
	thisFile=${ifile##*/}
	outfile=${outname}_$(echo ${thisFile%.nc} | sed 's/warmpool_//').tif
	./ncToGTiff.sh -w ${tmpdir} -o ${outdir}/${outfile} -n -1 -d warmpool -m ${maskSHP} ${indir}/${thisFile}
    done
}

# _________________
function do_regression(){
    bindir=/home/bruno/github/misc
    indir=/data/all_partners/lmes_productivity
    for ifile in ${indir}/*PPY-Y.CSV
    do
	code=$(echo ${ifile#*-} |  sed 's/-.*//')
	${bindir}/regressionLine.py -xval '1998,2013' -d ',' -xcol 3 -ycol 4 -skip 1 ${ifile} | while read line
	do
	    echo $code $line
	done
    done
}

# __________________________
function do_cleanLine(){
    bindir=/home/bruno/github/misc
    datadir=/data/tmp/new_algo/tos_rcp85_forpublication/out/
    ${bindir}/filter_verticalLine.py -o ${datadir}/interpolated_diff_decades_2050_2010.tif -of gtiff -co "compress=lzw" -lineDef 639 2 -lineDef 156 5 -lowerBound 0 -upperBound 10 ${datadir}/diff_decades_2050_2010_referenced.tif
}
# __________________________
# main: call the desired function
#ncToColor
# do_dhm
#do_wp rcp45

# do_regression

do_cleanLine

# end of script