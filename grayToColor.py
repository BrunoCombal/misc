#!/usr/bin/env python
# author: Bruno Combal
# date: February 2014

# Converts a gray level image to colored RGB(A) by using a look up table.

try:
    from osgeo import gdal
    from osgeo.gdalconst import *
    gdal.TermProgress = gdal.TermProgress_nocb
except ImportError:
    import gdal
    from gdalconst import *

import sys
import os
import os.path
import glob
import string
import math

# ________________________
def usage():
    text='SYNOPSIS:\n\tgrayToColor.py -o outfile [-b band] -lut lookuptable infile*'
    return text
# ________________________
def exitMessage(msg, exitCode='1'):
    print msg
    print 
    print usage()
    sys.exit(exitCode)
# ________________________
def do_fileIncrementedList(outName, nfiles):

    # separate basename from extensions
    thisBasename = os.path.basename(outName)
    splitted = thisBasename.split('.')

    # extension found?
    if len(splitted) > 1:
        extension=splitted[-1]
        del splitted[-1]

    # rebuild name
    rootName=os.path.join(os.path.dirname(outName), ''.join(splitted) )

    # build series
    outList=[]
    zeroPadding = int(math.log10(nfiles)) + 1
    for ii in range(nfiles):
        print ii
        outList.append( os.path.join(
                os.path.join( rootName, '_{0}'.format(str(ii).zfill(zeroPadding)) ),
                extension
                ))

    return outList  
# ________________________
def do_colorize(infileList, lut, outfileList):
    return
# ________________________
if __name__=="__main__":

    infile=[]
    outfileRoot=None
    lut=None
    bands=[]

    ii = 1
    while ii < len(sys.argv):
        arg = sys.argv[ii].lower()

        if arg == '-o':
            ii = ii + 1
            outfileGeneric = sys.argv[ii]
        elif arg== '-lut':
            ii = ii + 1
            lut = sys.argv[ii]
        else:
            infile.append(arg)
        ii = ii + 1

    # check input paramters
    if len(infile)==0:
        exitMessage('Missing input file(s). Exit(1)',1)
    if outfileGeneric is None:
        exitMessage('Please provide an output file name, use option -o. Exit(2).',2)
    if lut is None:
        exitMessage('Missing a look up table, use option -lut. Exit(3)',3)

    # check files
    for thisFile in infile:
        if not os.path.exists(thisFile):
            exitMessage('Input file {0} not found. Exit(10).'.format(thisFile),10)

    if not os.path.exists(lut):
        exitMessage('Look up table file {0} does not exists. Exit(11).'.format(lut), 11)

    # prepare a list of outfiles
    outfileList=do_fileIncrementedList(outfileGeneric, len(infile))

    print outfileList

    # call colorization function
    do_colorize(infile, lut, outfile)


# end of script
