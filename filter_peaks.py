#!/usr/bin/env python

# \author Bruno Combal, IOC-UNESCO
# \date July 2014

# removes peak values from a ncdf file
# peak definition: value >= peakVal and surrounding <= low or >= high
# This code was done for cleaning dhm_frequency datasets.
# It may requires adaptation for other kind of data

# note: to have cdms2 library correctly working 
# source /usr/local/uvcdat/1.2.0/bin/setup_cdat.sh

import cdms2
import numpy
import os
import string
import sys
import collections
import gc
# __________________
def usage():
    text = 'SYNOPSIS:\n\t{0} -low lowFilter -high highFilter -nodata nodata -o outputfileRoot infile*'.format(__file__)
    text = text + '\tinfile0: a series netcdf files. The first one is used to detect anomalous points to be removed;\n'
    text = text + '\toutputfileRoot root name for the output netcdf file. If exists, will be deleted;\n'
    text = text + '\tlowFilter: low values around the single point to remove;\n'
    text = text + '\thighFilter: high values around the point to remove;\n'
    text = text + '\nodata: nodata value, not changed;\n'
    print text
# __________________
def exitMessage(msg, exitCode='1'):
    print msg
    print
    print usage()
    sys.exit(exitCode)

# ___________________
def do_detect(infile, var, lowFilter, highFilter, nodata, outfile):
    
    thisFile = cdms2.open(infile)
    data = numpy.array(thisFile[var][:])

    pointList=[]
    pos=[]
    for jj in [-1, 0, 1]:
        for ii in [-1, 0, 1]:
            if ii or jj:
                pos.append([jj, ii])

    threshold = len(pos)

    # borders not processed!
    for il in xrange(1, data.shape[0]-1):
        for ic in xrange(1, data.shape[1]-1):
            
            if data[il][ic] == highFilter:
                counter = 0
                for (jj, ii) in pos:
                    # surrounding must be nodata or > lowFilter
                    if (data[il+jj][ic+ii] == nodata):
                        counter = counter + 1
                    elif (data[il+jj][ic+ii] <= lowFilter):
                        counter = counter + 1
                    elif (data[il+jj][ic+ii] >= highFilter):
                        counter = counter + 1
                    #test = test + (data[il+jj][ic+ii]!=nodata) * ( data[il+jj][ic+ii]<lowFilter)
                if counter >= threshold:
                    pointList.append([il, ic])

    thisFile.close()

    return pointList
# ___________________
def do_filter(infile, var, pointList, outfileRoot):

    pos=[]
    for jj in [-1, 0, 1]:
        for ii in [-1, 0, 1]:
            if ii or jj:
                pos.append([jj, ii])

    thisFile = cdms2.open(infile)
    data = None
    data = thisFile[var][:].copy() # else can not write in the dataset

    for (jj, ii) in pointList:
        around = []
        for (yy, xx) in pos: around.append(data[jj+yy][ii+xx])
        values = collections.Counter(around)
        data[jj][ii]=values.most_common(1)[0][0] # should work well with integers
    # let's write an output
    # get the file path
    thisPath = os.path.dirname(infile)
    # get the file name
    fname = os.path.basename(infile)
    # build the output: delete if exists
    outfile = os.path.join(thisPath, '{0}_{1}'.format(outfileRoot, fname) )
    if os.path.exists(outfile): os.remove(outfile)
    # write the file
    print 'writing result to ',outfile
    thisOut = cdms2.open(outfile,'w')
    var = cdms2.createVariable(data, id=var, grid=thisFile[var].getGrid())
    thisOut.write(var)
    thisOut.close()
    thisFile.close()
    del data
    del around
    gc.collect()

    return
# ___________________
if __name__=="__main__":
    
    infile=[]
    outfileRoot=None
    lowFilter=0
    highFilter=10
    nodata=-1
    var=None #'lvl2_freq'

    cdms2.setNetcdfShuffleFlag(1)
    cdms2.setNetcdfDeflateFlag(1)
    cdms2.setNetcdfDeflateLevelFlag(3)

    # read input parameter
    ii=1
    while ii < len(sys.argv):
        arg = sys.argv[ii].lower()
        if arg == '-o':
            ii = ii + 1
            outfileRoot = sys.argv[ii]
        elif arg=='-v':
            ii = ii + 1
            var = sys.argv[ii]
        else:
            infile.append(sys.argv[ii])
        ii = ii + 1

    # check parameters
    if outfileRoot is None:
        exitMessage('Missing an output file name, use option -o. Exit(2).',2)
    if len(infile)==0:
        exitMessage('Missing input file name(s). Exit(3).', 3)
    
    for thisFile in infile:
        if not os.path.exists(thisFile):
            exitMessage('Input file does not exist. Exit(4).',4)


    print 'Getting reference points: '
    pointList = do_detect(infile[0], var, lowFilter, highFilter, nodata, outfileRoot)
    if len(pointList)==0:
        exitMessage('Found no point to correct')

    print 'Found {0} points'.format(len(pointList))

    # now filter all files in the series
    for thisFile in infile:
        do_filter(thisFile, var, pointList, outfileRoot)


# end of script
