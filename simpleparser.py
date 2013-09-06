import os

#BASE_DIR = '/mnt/testouts/initial/stor02_fio_large_weds21/'
#BASE_DIR = '/Users/ace/perftesting/testouts/J02FIO/'
BASE_DIR = '/Users/ace/perftesting/smfio/stor02_fio_100GB_fri23/'

def main():
    outstr = ""
    #first we find all the target files
    target_file_paths = get_target_file_paths()
    print target_file_paths
    target_file_paths.sort()
    #then we parse them
    for target in target_file_paths:
        outstr += '********** ' + target + ' **********\n'
        outstr = outstr + parse_target(target)
    #then we print them
    print outstr

def parse_target(target):
    outstr = ""
    #first open file
    tfile = open(BASE_DIR + target)
    #next extract relevent lines
    #first skip first few lines
    tfile.readline()#YCSB client
    tfile.readline()#commandline call
    tfile.readline()#connection line
    #grab overall lines
    outstr += tfile.readline()#overall runtime
    outstr += tfile.readline()#overall throughput
    #loop over file till end
    #grab out all lines with "Operations" and the next 5 lines
    line = tfile.readline()
    while line:
        if "Operations" in line and "CLEANUP" not in line:
            outstr += line #Operations
            outstr += tfile.readline() #AvgLat
            outstr += tfile.readline() #MinLat
            outstr += tfile.readline() #MaxLat
            outstr += tfile.readline() #95
            outstr += tfile.readline() #99
        line = tfile.readline()
    #return string
    return outstr
    

def get_target_file_paths():
    targets = []
    #find all files in the base_dir
    files = os.listdir(BASE_DIR)
    for file in files:
        if 'workload' in file:
            targets.append(file)
    return targets

if __name__ == '__main__':
    main()
