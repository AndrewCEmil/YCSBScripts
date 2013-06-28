#!/bin/bash
# completerun.sh is for doing the complete fusionIO performance testing.  It breaks into a few 
# sections: 
# 1) initialization + parsing command line opts
# 2) storing data about the system and its state
# 3) starting instrumenting programs
# 4) running through actual testing
# 5) clean up

#assumptions:
#-DB has the cleandb.sh in the home directory
#-Client has ycsbrun.sh and ycsbparser in home directory
#-Both machines do not require tty for sudo (turn off in /etc/sudoers)

#1) Initialization and command line parsing
DBURL="10gencasvr.local"
CLEANDBP="/home/ace/cleandb.sh"
OUTDIR="/Users/ace/perftesting/testouts/complete"
KEYP="/Users/ace/perftesting/keys/10gencasvr_root_key"
YCSBP="/Users/ace/achilleYCSB/YCSB/bin/ycsb"
WORKLOADP="/Users/ace/perftesting/workloads"
USRNAME="ace"
NUMTHREADS="100"

#2) Storing system data TODO


#3) Instrumenting systems TODO
ssh -i $KEYP root@$DBURL mpstat -P ALL 1 > $OUTDIR/mpstat &
MPSTATPID=$!
ssh -i $KEYP root@$DBURL iostat -d -x -h 1 > $OUTDIR/iostat &
IOSTATPID=$!

#4) actual testing
#First clean/restart the database 
ssh -i $KEYP root@$DBURL $CLEANDBP
#next, workloada
$YCSBP load mongodb -P $WORKLOADP/workloada -threads $NUMTHREADS > $OUTDIR/workloada_load
$YCSBP run mongodb -P $WORKLOADP/workloada -threads $NUMTHREADS > $OUTDIR/workloada_run
#workloadc is readonly, so we can run it without loading again
$YCSBP run mongodb -P $WORKLOADP/workloadc -threads $NUMTHREADS > $OUTDIR/workloadc_run
#workloadf is read/update only, we run without loading again
$YCSB run mongodb -P $WORKLOADP/workloadf -threads $NUMTHREADS > $OUTDIR/workloadf_run
#clean db, workloadb
ssh -i $KEYP root@$DBURL $CLEANDBP
$YCSBP load mongodb -P $WORKLOADP/workloadb -threads $NUMTHREADS > $OUTDIR/workloadb_load
$YCSBP run mongodb -P $WORKLOADP/workloadb -threads $NUMTHREADS > $OUTDIR/workloadb_run
#clean db workloadd
ssh -i $KEYP root@$DBURL $CLEANDBP
$YCSBP load mongodb -P $WORKLOADP/workloadb -threads $NUMTHREADS > $OUTDIR/workloadd_load
$YCSBP run mongodb -P $WORKLOADP/workloadb -threads $NUMTHREADS > $OUTDIR/workloadd_run
#clean db workloade
ssh -i $KEYP root@$DBURL $CLEANDBP
$YCSBP load mongodb -P $WORKLOADP/workloade -threads $NUMTHREADS > $OUTDIR/workloade_load
$YCSBP run mongodb -P $WORKLOADP/workloade -threads $NUMTHREADS > $OUTDIR/workloade_run

#5) cleanup
kill $MPSTATPID
kill $IOSTATPID
