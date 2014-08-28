#!/bin/bash

# \author: Bruno Combal, IOC/UNESCO
# \date: 2013, December


function test(){
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
# main: call the desired function
ncToColor

# end of script