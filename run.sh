#!/bin/bash

# \author: Bruno Combal, IOC/UNESCO
# \date: 2013, December

indir=/data/tmp/new_algo/dhm_rcprcp85/
outdir=/data/tmp/new_algo/export_tif
maskSHP=/data/tmp/new_algo/landMask.shp
decade=2030
decadeEnd=$((decade+10))
mkdir -p $outdir
tmpdir=$outdir/tmp
mkdir -p $tmpdir

nodata=-1
./ncToGTiff.sh -o ${outdir}/frequency_lvl2_${decade}.tif -n $nodata -m ${maskSHP} -d lvl2_freq -w ${tmpdir} ${indir}/frequency_lvl2_${decade}.nc 

# gdalrasterize does not understand 1.e20
nodata=100000000000000000000
./ncToGTiff.sh -w ${tmpdir} -o ${outdir}/dhm_decade_${decade}.tif -n $nodata -d dhm -w tmp -m ${maskSHP} -p ${indir} `for ((ii=${decade}; ii<${decadeEnd}; ii++)); do echo dhm_${ii}.nc; done`


# end of script