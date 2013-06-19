import pymongo
import sys
#import matplotlib.pyplot as plt

from datetime import datetime

pathname = "/home/ec2-user/"
elenum = "0"

def fullrun():
    #generate filenames
    if len(sys.argv) > 1:
        elenum = sys.argv[1]
    loadfilename = pathname + "loadout" + elenum
    testfilename = pathname + "testout" + elenum
    #TODO try/catch
    print "opening files..."
    loadfile = open(loadfilename)
    testfile = open(testfilename)
    print "parsing load file"
    loadres = parseout(loadfile, True)
    print "parsing test file"
    testres = parseout(testfile, False)
    print "LOADRES:"
    print loadres
    print "TESTRES:"
    print testres

def parseout(infile, isload):
    #skip a few header lines
    print "looping over headers"
    currentline = infile.readline()
    while("OVERALL" not in currentline):
        currentline = infile.readline()

    #overall section
    print "handling overall section"
    sectionname = "OVERALL"
    RunTimeMs = float(currentline.split(',')[2])
    currentline = infile.readline()
    throughput = float(currentline.split(',')[2])
    results = { "OVERALL" : { "throughput" : throughput, "RunTimeMs" : RunTimeMs}}

    #loop over normal histogram data
    if isload:
        sectionnames = ["INSERT"]
        results["INSERT"] = {}
    else:
        sectionnames = ["UPDATE", "READ"]
        results["UPDATE"] = {}
        results["READ"] = {}

    print "handling main data"
    sectionidx = 0
    currentline = infile.readline()
    while True:
        print "handling header data"
        cursection = sectionnames[sectionidx]
        #first handle the header for the new section
        results[cursection]["ops"] = currentline.strip().split(',')[2]
        results[cursection]["avglat"] = float(infile.readline().strip().split(',')[2])
        results[cursection]["minlat"] = float(infile.readline().strip().split(',')[2])
        results[cursection]["maxlat"] = float(infile.readline().strip().split(',')[2])
        results[cursection]["95lat"] = float(infile.readline().strip().split(',')[2])
        results[cursection]["99lat"] = float(infile.readline().strip().split(',')[2])

        #TODO what is this next line? for now skip it
        infile.readline()

        print "handling histogram data"
        currentline = infile.readline()
        while(cursection in currentline):
            #results[cursection]["histogram"].append(currentline.strip().split(',')[2])
            #for now just skip the histogram lines
            currentline = infile.readline()
        sectionidx += 1
        if sectionidx >= len(sectionnames):
            break
    print "returning results"
    return results

#plt.plot(results["UPDATE"]["histogram"][0:5])
#plt.plot(histograms["READ"])
#plt.show()

#insert results into databse
#client = pymongo.MongoClient()
#db = client['ycsbResults']
#coll = db['results']
#results['ts'] = datetime.now()
#coll.insert(results)

fullrun()
