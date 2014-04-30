#!/bin/bash

# \author: Bruno Combal, IOC/UNESCO
# \date: 2013, December

rcp='rcp85'

indir='/data/tmp/new_algo/dhm_rcp'${rcp}'/'
outdir=/data/tmp/new_algo/export_tif
maskSHP=/data/tmp/new_algo/landMask.shp
mkdir -p $outdir
tmpdir=$outdir/tmp
mkdir -p $tmpdir


for decade in 2030 2040 2050
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



# end of script