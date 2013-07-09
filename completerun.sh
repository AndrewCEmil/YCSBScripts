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
#CLEANDBP="/home/ace/cleandbdisk.sh"
#CLEANDBP="/home/ace/cleandbseperate.sh"
OUTDIR="/Users/ace/perftesting/testouts/J08RAID2"
KEYP="/Users/ace/perftesting/keys/10gencasvr_root_key"
YCSBP="/Users/ace/achilleYCSB/YCSB/bin/ycsb"
WORKLOADP="/Users/ace/perftesting/workloads"
#a file for the recordcount and operation count
WORKLOADCOUNTP="/Users/ace/perftesting/workloads/counts"
USRNAME="ace"
NUMTHREADS="100"
rm -rf $OUTDIR/*
mkdir $OUTDIR

#2) Storing system data TODO


#3) Instrumenting systems 
ssh -i $KEYP root@$DBURL mpstat -P ALL 1 > $OUTDIR/mpstat &
MPSTATPID=$!
ssh -i $KEYP root@$DBURL iostat -d -x -h 1 > $OUTDIR/iostat &
IOSTATPID=$!
ssh -i $KEYP root@$DBURL mongostat > $OUTDIR/mongostat &
MONGOSTATPID=$!

#4) actual testing
#workloada
ssh -i $KEYP root@$DBURL $CLEANDBP
echo "loading workloada"
$YCSBP load mongodb -P $WORKLOADP/workloada -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloada_load
echo "running workloada"
$YCSBP run mongodb -P $WORKLOADP/workloada -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloada_run
#workloadb
ssh -i $KEYP root@$DBURL $CLEANDBP
echo "loading workloadb"
$YCSBP load mongodb -P $WORKLOADP/workloadb -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadb_load
echo "running workloadb"
$YCSBP run mongodb -P $WORKLOADP/workloadb -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadb_run
#workloadc
ssh -i $KEYP root@$DBURL $CLEANDBP
echo "loading workloadc"
$YCSBP load mongodb -P $WORKLOADP/workloadc -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadc_load
echo "running workloadc"
$YCSBP run mongodb -P $WORKLOADP/workloadc -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadc_run
#workloadd
ssh -i $KEYP root@$DBURL $CLEANDBP
echo "loading workloadd"
$YCSBP load mongodb -P $WORKLOADP/workloadd -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadd_load
echo "running workloadd"
$YCSBP run mongodb -P $WORKLOADP/workloadd -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadd_run
#workloade
ssh -i $KEYP root@$DBURL $CLEANDBP
echo "loading workloade"
$YCSBP load mongodb -P $WORKLOADP/workloade -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloade_load
echo "running workloade"
$YCSBP run mongodb -P $WORKLOADP/workloade -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloade_run
#workloadf
ssh -i $KEYP root@$DBURL $CLEANDBP
echo "loading workloadf"
$YCSBP load mongodb -P $WORKLOADP/workloadf -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadf_load
echo "running workloadf"
$YCSBP run mongodb -P $WORKLOADP/workloadf -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadf_run
#5) cleanup
kill $MPSTATPID
kill $IOSTATPID
kill $MONGOSTATPID
