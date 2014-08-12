#!/usr/bin/env python

# convert a csv into a wkt
# note: original script found on http://gis.stackexchange.com/questions/58894/qgis-import-polygons-in-csv

import os
import sys
csvFolder = r"C:\myFolder\mySubFolder"


# ____________________________
def usage():
    textUsage='SYNOPSIS:\n\tcsv2wkt.py \n'

    return textUsage
# ____________________________
def exitMessage(msg, exitCode='1'):
    print msg
    print
    print usage()
    sys.exit(exitCode)
#_______________________________________
def writePolyToFile(outFile, polygon, polyId):
    wkt = "POLYGON((" + ','.join(polygon) + "))\n"
    outFile.write(str(polyId) + ';' + wkt)
#________________________________________
def makePolys(inPath, outPath):
    try:
        with open(inPath,'r') as inFile:
            contents = inFile.readlines()
            polyId = 0
            thisPolyName = ''
            polygon = []

            for line in contents:
                line = line.rstrip('\n')
                if polyId == 0:

                    if line.lower().replace(" ","") != 'name,x,y' and line.lower().replace(" ","") !='name,longitude,latitude':
                        exitMessage('Unexpected header in {0}. Must be name, x, y or name, longitude, latitude. Exit(10).'.format(inPath), 10)
                        break

                    outFile = open(outPath,'w')
                    outFile.write("id;wkt\n")
                    polyId += 1

                elif len(line) == 0:
                    writePolyToFile(outFile, polygon, polyId)
                    polygon = []
                    polyId += 1

                else:
                    polygon.append(line[1:].replace(',',' '))

        writePolyToFile(outFile, polygon, polyId) #append the last polygon after EOF
        outFile.close()
        print('Conversion to WKT OK for', inPath)

    except:
        print('WARNING: conversion to WKT failed for', inPath)
#_______________________________________________
def iterateFiles():
    csvFiles = [each for each in os.listdir(csvFolder) if each.endswith('.csv')]

    for file in csvFiles:
        inPath = os.path.join(csvFolder, file)
        newName = "WKT_" + file
        outPath = os.path.join(csvFolder, newName)
        makePolys(inPath, outPath)
#_______________________________________________

if __name__ == "__main__":

    outfile=None
    ifile=None

    ii = 1
    while ii < len(sys.argv):
        arg = sys.argv[ii].lower()
        if arg == '-o':
            ii = ii + 1
            outfile = sys.argv[ii]
        else:
            infile = sys.argv[ii]
        

    if infile is None:
        exitMessage('Missing input file name. Exit(1).',1)
    if outfile is None:
        exitMessage('Missing output file name. Exit(2).',2)
    if not os.path.exists(infile):
        exitMessage('input file not found. Exit(3).',3)

    makePolys(infile, outfile)

# end of script
