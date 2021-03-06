#!/usr/bin/env python

# \author Bruno Combal, IOC-UNESCO
# \date February 2014
# makes a time series from a list of netcdf files

# to run the script with the correct version of uvcdat:
#  source /usr/local/uvcdat/1.4.0/bin/setup_runtime.sh

import cdms2
import os
import sys
import numpy
# __________
def usage():
    text='SYNOPSIS:\n\ttimeConcatNC.py -v variable -o outfile file*'
    return text
# __________
def exitMessage(msg, exitCode='1'):

    print msg
    print
    print usage()
    sys.exit(exitCode)
# __________
def do_concatenate(infiles, var, outfile):
    
    data=None
    grid=None

    for index, thisName in enumerate(infiles):
        print '{1}: Opening file {0}'.format(thisName, index)
        thisFile=cdms2.open(thisName, 'r')
        if not var in thisFile.variables.keys():
            exitMessage('Variable {0} not found in file {1}. Exit 100.'.format(var, thisName),100)
        if data is None:
            thisShape = thisFile[var][:].shape
            data = numpy.zeros( (len(infiles), thisShape[0], thisShape[1]) )+1.e20
        data[index]=thisFile[var][:]
        grid=thisFile[var].getGrid()
        thisFile.close()
    
    outdata=cdms2.createVariable(data, typecode='f', id=var, fill_value=1.e20)
    outdata.setGrid(grid)
    outHD = cdms2.open(outfile, 'w')
    outHD.write(outdata)
    outHD.close()
# __________
if __name__=="__main__":

    outfile=None
    infile=[]
    var=None

    ii = 1
    while ii < len(sys.argv):
        arg = sys.argv[ii].lower()

        if arg == '-o':
            ii = ii + 1
            outfile = sys.argv[ii]
        elif arg == '-var' or arg=='-v':
            ii = ii + 1
            var = sys.argv[ii]
        else:
            infile.append(sys.argv[ii]) # no lower case here!
        ii = ii + 1

    # check inputs
    if outfile is None:
        exitMessage('Missing an outpuf file name, use -o. Exit 1.', 1)
    if var is None:
        exitMessage('Missing a variable name, use -var. Exit 2.',2)
    if len(infile)==0:
        exitMessage('Missing input files. Exit 3.', 3)

    # check input files
    for thisFile in infile:
        if not os.path.exists(thisFile):
            exitMessage('Input file {0} does not exist. Exit 10.'.thisFile, 10)

    # seems ok, call concatenation code
    do_concatenate(infile, var, outfile)
