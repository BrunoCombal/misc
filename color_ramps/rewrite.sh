#/bin/bash

infile='3gauss.rgb'
outfile='3gauss.sld'

startVal=271
endVal=304
val=${startVal}

steps=`tail -n +3 ${infile} | wc -l`
increment=`echo "scale=20;(${endVal} - ${startVal})/ (${steps}-1)" | bc`

tail -n +3 ${infile} | while read line r g b
do
    rhex=`printf '%02x' ${r}`
    ghex=`printf '%02x' ${g}`
    bhex=`printf '%02x' ${b}`
    
    thisVal=`printf '%.4f' ${val}`
    echo '<sld:ColorMapEntry color="#'${rhex}${ghex}${bhex}'" label="'${thisVal}'" opacity="1.0" quantity="'${thisVal}'"/>'

    val=`echo "scale=20; ${val} + ${increment}" | bc`
done