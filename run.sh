#!/bin/bash

# \author: Bruno Combal, IOC/UNESCO
# \date: 2013, December

mkdir /data/tmp/new_algo/export_tif

./ncToGTiff.sh -o /data/tmp/new_algo/export_tif/frequency_lvl2_2050.tif -d lvl2_freq -w tmp /data/tmp/new_algo/dhm_rcprcp85/frequency_lvl2_2050.nc 

./ncToGTiff.sh -o /data/tmp/new_algo/export_tif/dhm_decade_2050.tif -d dhm -w tmp -p /data/tmp/new_algo/dhm_rcprcp85/ `for ((ii=2050; ii<2060; ii++)); do echo dhm_${ii}.nc; done`


# end of script