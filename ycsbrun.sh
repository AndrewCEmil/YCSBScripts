#!/bin/bash
FNAME="/Users/ace/perftesting/testouts/testout`date +%s`"
echo $FNAME
date >> $FNAME
/Users/ace/YCSB/bin/ycsb load mongodb -P /Users/ace/YCSB/workloads/workloada >> $FNAME
date >> $FNAME
/Users/ace/YCSB/bin/ycsb run mongodb -P /Users/ace/YCSB/workloads/workloada >> $FNAME
date >> $FNAME
