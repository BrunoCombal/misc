#!/bin/bash

# \author: Bruno Combal, IOC/UNESCO
# \date: 2013, December

# note: uses gdal_translate.
# usage: ncToGTiff.sh -o outFile -d datasetname[-w tmpdir] file*

# ____________________
function exitMessage(){
    echo "Usage: ncToGTiff.sh -o OUTFILE -d DATASETNAME [-b 'ulx uly lrx lry'] [-w TMPDIR] FILE*"
    exit 1
}
# __________ main _____________
outName=''
ncdfType='NETCDF'
tmpdir='.'
datasetname=''
bbox='0 85 360 -85'

while getopts ":o:d:b:w:" opt; do
    case $opt in
	o) outName=${OPTARG};;
	d) datasetname=${OPTARG};;
	b) bbox=(${OPTARG});;
	w) tmpdir=${OPTARG};;
	\?) echo "Invalid option: -$OPTARG" >&2
	    exitMessage
	    ;;
	:) exitMessage ;;
    esac
done

# now get input file names
shift $(($OPTIND - 1))
lstFiles=$@

if [ -z $outName ]; then
    echo "Missing an output file name. Use option -o. Exit."
    exitMessage
fi

if [ -z $datasetname ]; then
    echo "Dataset name is not defined. Use option -d. Exit."
    exitMessage
fi

# create tmp if specfied
mkdir -p $tmpdir

# force remove outname
rm -f ${outName} 

for ii in ${lstFiles[@]}
do
    tmpfile=${tmpdir}/${0##*/}_${RANDOM}${RANDOM}.nc
    if [ -e ${tmpfile} ]; then
	echo "tmpfile $tmpfile already exists. Consider cleaning the working directory. Exit."
	exitMessage
    fi
    tmpOut=${tmpdir}/tmp_${0##*/}_${RANDOM}${RANDOM}.tif
    if [ -e ${tmpOut} ]; then
	echo "tmp file $tmpOut already exists. Consider cleaning the working directory. Exit."
	exitMessage
    fi

    echo "${ii##*/}:${} to netcdf"
    gdal_translate -of netcdf -co "write_bottomup=no" -co "write_lonlat=yes" ${ncdfType}':"'${ii}'":'${datasetname} ${tmpfile}
    # append srs and bbox
    gdal_translate -of gtiff -co "compress=lzw" -a_srs 'EPSG:4326' -a_ullr 0 85 360 -85 ${tmpfile} ${tmpOut}
    rm -rf {tmpfile}

    # append the layer to the final file
    if [ -e ${outName} ]; then
	mv ${tmpOut} ${outName}
	echo $ii > ${outName}.meta
    else
	gdal_merge.py -separate -of gtiff -co "compress=lzw" -n 1.e20 -o ${outName} ${outName} ${tmpOut}
	echo $ii >> ${outName}.meta
    fi
done

# end of script