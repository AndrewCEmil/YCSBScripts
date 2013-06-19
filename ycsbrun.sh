#!/bin/bash
#FNAME="/Users/ace/perftesting/testouts/testout`date +%s`"
read TESTNUM
LOADNAME="/home/ec2-user/perftesting/testouts/loadout"$TESTNUM
TESTNAME="/home/ec2-user/perftesting/testouts/testout"$TESTNUM

/home/ec2-user/YCSB/bin/ycsb load mongodb -P /home/ec2-user/YCSB/workloads/workloada >> $LOADNAME
/home/ec2-user/YCSB/bin/ycsb run mongodb -P /home/ec2-user/YCSB/workloads/workloada >> $TESTNAME
