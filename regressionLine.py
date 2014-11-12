#!/usr/bin/env python

# author: Bruno Combal, IOC-Unesco
# date: November 2014

import numpy
import os
import string
import sys
# _________________________________
def usage():
    text='SYNOPSIS:\n\regressionLine.py [-d delimiter] [-skip number] [-xcol number] [-ycol number] [-xval listOfXval] input.csv'
    text = text+'\tinput.csv: A csv (comma separated file) containing the data for computing the regression line. Column 1: x, Column 2: y\n'
    text = text+'\t-d delimiter: Defines a data delimiter; default delimiter is ","\n'
    text = text+'\tskip number: number of lines to skip; default is 0\n'
    text = text+'\txcol number: position of the x-values column; default is 0\n'
    text = text+'\tycol number: position of the y-values column; default is 1\n'
    text = text+'\txval listOfXval: a comma separated list of xvalues to evaluate the regression line; for example write -xval "1998,2013". Default is to output the regression parameter as slope and bias (y=slope.x + bias)\n'
    return text
# _________________________________
def exitMessage(msg, exitCode='1'):
    print msg
    print
    print usage()
    sys.exit(exitCode)

# _________________________________
def do_readData(infile, skip, delimiter, xcol, ycol):

    iskip=0
    xval=[]
    yval=[]
    # read data
    with open(infile, 'r') as fid:
        for line in fid:
            if iskip < skip:
                iskip = iskip + 1
            else:
                thisData = string.split(line, delimiter)
                xval.append(float(thisData[xcol]))
                yval.append(float(thisData[ycol]))

    return [xval, yval]
# _________________________________
def do_regressionLine(infile, skip, delimiter, xcol, ycol, xval):
    
    (x, y) = do_readData(infile, skip, delimiter, xcol, ycol)

    regression = numpy.polyfit(x, y, 1)
    if xval is None:
        print regression
    else:
        for ii in xval:
            print ii, regression[0]*ii + regression[1]

# _________________________________
def do_listToArray(listVal):
    tmp = string.split(listVal,',')
    data=[]

    for ii in tmp:
        data.append(float(ii))
    return data
# _________________________________
if __name__=="__main__":
    infile=None
    delimiter=','
    skip=0
    xcol=0
    ycol=1
    xval=None

    ii = 1
    while ii < len(sys.argv):
        arg = sys.argv[ii].lower()
        if arg == '-d':
            ii = ii + 1
            delimiter=sys.argv[ii]
        if arg == '-skip':
            ii = ii + 1
            skip = int(sys.argv[ii])
        if arg == '-xcol':
            ii = ii + 1
            xcol = int(sys.argv[ii])
        if arg == '-ycol':
            ii = ii + 1
            ycol = int(sys.argv[ii])
        if arg=='-xval':
            ii = ii + 1
            xval = do_listToArray(sys.argv[ii])
        else:
            infile = sys.argv[ii]

        ii = ii + 1

    if infile is None:
        exitMessage('Missing an input file. Exit(1).',1)
    if not os.path.exists(infile):
        exitMessage('Input file {0} does not exist. Exit(2)'.format(infile), 2)

    do_regressionLine(infile, skip, delimiter, xcol, ycol, xval)

# end of code
