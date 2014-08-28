#!/bin/bash

# \author: Bruno Combal, IOC/UNESCO
# \date: 2013, December

# note: uses gdal command line.
# usage: ncToGTiff.sh -o outFile -d datasetname[-w tmpdir] file*

# ____________________
function exitMessage(){
    echo "Usage: ncToGTiff.sh [-c colormap] [-s src_min src_max dst_min dst_max] -o OUTFILE -d DATASETNAME)) [-b 'ulx uly lrx lry'] [-w TMPDIR] [-m maskSHP] [-p INPUTDATAPATH] [-n outnodata] FILE*"
    exit 1
}
# __________ main _____________
outName=''
ncdfType='NETCDF'
tmpdir='.'
datasetname=''
bbox='0 85 360 -85'
mask=''
nodata=1.e20
inpath=''

while getopts ":o:d:b:w:m:n:p:c:s:" opt; do
    case $opt in
	o) outName=${OPTARG};;
	d) datasetname=${OPTARG};;
	b) bbox=(${OPTARG});;
	w) tmpdir=${OPTARG};;
	m) mask=${OPTARG};;
	n) nodata=${OPTARG};;
	p) inpath=${OPTARG};;
	c) colorMap=${OPTARG};;
	s) linScale=(${OPTARG});;
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

if [ -n $mask ]; then
    if [ ! -e $mask ]; then
	echo "mask file ${mask}  does not exist. Exit"
	exitMessage
    fi
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

    echo "${ii##*/}:${datasetname} to flat netcdf: ${tmpfile}"
    if [ -z "${inpath}" ]; then
	thisfile=$ii
    else
	thisfile=${inpath}/${ii}
    fi
    gdal_translate -of netcdf -co "write_bottomup=no" -co "write_lonlat=yes" ${ncdfType}':"'${thisfile}'":'${datasetname} ${tmpfile}
    echo  gdal_translate -of netcdf -co "write_bottomup=no" -co "write_lonlat=yes" ${ncdfType}':"'${thisfile}'":'${datasetname} ${tmpfile}
    exit
    # append srs and bbox
    echo ${tmpfile} " to GTiff: ${tmpOut}"
    # rescale command
    rescale=''
    if [ -e "$linScale" ]; then
	rescale="-scale ${OPTARG[@]}"
    fi
    gdal_translate $rescale -of gtiff -co "compress=lzw" -a_srs 'EPSG:4326' -a_ullr ${bbox[@]} ${tmpfile} ${tmpOut}
    rm -rf {tmpfile}

    # append the layer to the final file
    if [ -e ${outName} ]; then
	waiting=${tmpdir}/wait_${RANDOM}${RANDOM}_${outName##*/}
	mv ${outName} ${waiting}
	gdal_merge.py -separate -of gtiff -co "compress=lzw" `[ -n "$nodata" ] && echo -n "-n ${nodata}"` -o ${outName} ${waiting} ${tmpOut}
	rm -f ${waiting}
	echo ${thisfile##*/} >> ${outName}.meta
    else
	mv ${tmpOut} ${outName}
	echo ${thisfile##*/} > ${outName}.meta
    fi
done

exit

# apply color mapping
if [ -e "$colorMap" ]; then
    cp -f ${outName} ${tmpOut}
    rm -f ${outName}
    gdaldem color-relief ${tmpOut} ${colorMap} ${outName}
fi

# apply mask if needed
if [ -n "${mask}" ]; then
    layername=$(ogrinfo -al -geom=NO ${mask} | grep 'Layer name:' | sed 's/.*://')
    nlayer=$(gdalinfo -norat -nogcp -noct ${outName} | grep -e 'Band [0-9]* Block.*Type.*' | wc -l)
    echo $nlayer
    for ((ib=1; ib<${nlayer}; ib++))
    do
	echo "Masking layer ${ib}"
	gdal_rasterize -b ${ib} `[ -n "$nodata" ] && echo -n "-burn ${nodata}"` -l ${layername} $mask ${outName}
    done
fi



# end of script