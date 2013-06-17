import pymongo
import matplotlib.pyplot as plt

from datetime import datetime

filename = "/Users/ace/perftesting/testouts/newVolTest4"
lineheader = "[{0}], "
RunTimeMs = -1
throughput = -1
infile = open(filename)

#skip a few header lines
infile.readline() #YCSB Client 0.1
infile.readline() #Command line: ...
infile.readline() #new database url = ...
infile.readline() #mongo connection created

#overall section
sectionname = "OVERALL"
runtime_line = infile.readline()
if not runtime_line.startswith(lineheader.format(sectionname)):
    print "error!!!!" #TODO turn to exception
RunTimeMs = float(runtime_line.split(',')[2])
runtime_line = infile.readline()
if not runtime_line.startswith(lineheader.format(sectionname)):
    print "error!!!!" #TODO turn to exception
throughput = float(runtime_line.split(',')[2])
print RunTimeMs
print throughput 

#loop over normal histogram data
sectionnames = ["UPDATE", "READ"]
sectionidx = 0
currentline = infile.readline()
results = { "UPDATE" : { "histogram" : [] }, "READ": { "histogram" : [] } }
#forgot to put this in before
results["OVERALL"] = { "throughput" : throughput, "RunTimeMs" : RunTimeMs}
newsection = True
while True:
    cursection = sectionnames[sectionidx]
    if newsection:
        #handle the header for the new section
        results[cursection]["ops"] = currentline.strip().split(',')[2]
        results[cursection]["avglat"] = float(infile.readline().strip().split(',')[2])
        results[cursection]["minlat"] = float(infile.readline().strip().split(',')[2])
        results[cursection]["maxlat"] = float(infile.readline().strip().split(',')[2])
        results[cursection]["95lat"] = float(infile.readline().strip().split(',')[2])
        results[cursection]["99lat"] = float(infile.readline().strip().split(',')[2])
        #TODO what is this next line?
        infile.readline()
        currentline = infile.readline()
    while(currentline.startswith(lineheader.format(cursection))):
        results[cursection]["histogram"].append(currentline.strip().split(',')[2])
        currentline = infile.readline()
    sectionidx += 1
    if sectionidx >= len(sectionnames):
        break

#plt.plot(results["UPDATE"]["histogram"][0:5])
#plt.plot(histograms["READ"])
#plt.show()

#insert results into databse
#client = pymongo.MongoClient()
#db = client['ycsbResults']
#coll = db['results']
#results['ts'] = datetime.now()
#coll.insert(results)

print results
