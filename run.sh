#!/bin/bash

# \author: Bruno Combal, IOC/UNESCO
# \date: 2013, December
# provides examples showing how to use others scripts

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

### main
# do_dhm
do_wp rcp45

# end of script