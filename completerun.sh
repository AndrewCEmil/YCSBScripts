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
#the config file
$RUNCONFFILE="./run.conf"
source $RUNCONFFILE

rm -rf $OUTDIR/*
mkdir $OUTDIR

#3) Instrumenting systems 
ssh -i $KEYP root@$DBURL mpstat -P ALL 1 > $OUTDIR/mpstat &
MPSTATPID=$!
ssh -i $KEYP root@$DBURL iostat -d -x -h -t 1 > $OUTDIR/iostat &
IOSTATPID=$!

#4) actual testing
#workloada
ssh -i $KEYP root@$DBURL $CLEANDBP
ssh -i $KEYP root@$DBURL $MSTAT >> $OUTDIR/mongostat &
echo "loading workloada" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP load mongodb -P $WORKLOADP/workloada -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloada_load

echo "running workloada" | tee -a $OUTDIR/runout
echo `date` | tee -a $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloada -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloada_run
#workloadb
echo "running workloadb" | tee -a $OUTDIR/runout
echo `date` | tee -a $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadb -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadb_run
echo "running workloadc" | tee -a $OUTDIR/runout
echo `date` | tee -a $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadc -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadc_run
echo "running workloadf" | tee -a $OUTDIR/runout
echo `date` | tee -a $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadf -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadf_run

#workloadd
ssh -i $KEYP root@$DBURL $CLEANDBP
ssh -i $KEYP root@$DBURL $MSTAT >> $OUTDIR/mongostat &
echo "loading workloadd" | tee -a $OUTDIR/runout
echo `date` | tee -a $OUTDIR/runout
$YCSBP load mongodb -P $WORKLOADP/workloadd -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadd_load
echo "running workloadd" | tee -a $OUTDIR/runout
echo `date` | tee -a $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadd -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadd_run
#workloade
ssh -i $KEYP root@$DBURL $CLEANDBP
ssh -i $KEYP root@$DBURL $MSTAT >> $OUTDIR/mongostat &
echo "loading workloade" | tee -a $OUTDIR/runout
echo `date` | tee -a $OUTDIR/runout
$YCSBP load mongodb -P $WORKLOADP/workloade -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloade_load
echo "running workloade" | tee -a $OUTDIR/runout
echo `date` | tee -a $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloade -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloade_run

#5) cleanup
kill $MPSTATPID
kill $IOSTATPID
