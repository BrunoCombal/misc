#!/usr/bin/env python

# \author Bruno Combal, IOC-UNESCO
# \date February 2014
# makes a time series from a list of netcdf files

# to run the script with the correct version of uvcdat:
#  source /usr/local/uvcdat/1.4.0/bin/setup_runtime.sh

import cdms2
import os
# __________
def usage():
    text='SYNOPSIS:\n\ttimeConcatNC.py -v variable -o outfile file*'
    return text
# __________
def exitMessage(msg, exitCode='1'):
    thisLogger.critical(msg)
    print msg
    print
    print usage()
    sys.exit(exitCode)
# __________
def do_concatenate(infile, var, outfile):
    continue
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
