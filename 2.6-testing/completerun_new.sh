h is for doing the complete fusionIO performance testing.  It breaks into a few
# sections:
# 1) initialization + parsing command line opts
# 2) storing data about the system and its state
# 3) starting instrumenting programs
# 4) running through actual testing
# 5) clean up

#CLEANDBP=$1
OUTDIR=$1

#1) Initialization and command line parsing
DBURL="10.5.22.233"
YCSBP="/mnt/workspace/YCSBScripts/YCSB/bin/ycsb"
WORKLOADP="/mnt/workspace/YCSBScripts/YCSB/workloads"
#a file for the recordcount and operation count
WORKLOADCOUNTP="/mnt/workspace/YCSBScripts/2.6-testing/baseconfig"
NUMTHREADS="10"
#local path to mongo shell for dropping db
MONGOPATH="/mnt/workspace/mongo/mongo"

rm -rf $OUTDIR/*
mkdir $OUTDIR

#3) Instrumenting systems
#TURNED OFF for now
#ssh -i $KEYP root@$DBURL mpstat -P ALL 1 > $OUTDIR/mpstat &
#MPSTATPID=$!
#ssh -i $KEYP root@$DBURL iostat -t -d -x -h 1 > $OUTDIR/iostat &
#IOSTATPID=$!

#4) actual testing
#workloada
$MONGOPATH --host $DBURL --eval "db.getSiblingDB('ycsb').dropDatabase()"
echo "loading workloada" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP load mongodb -P $WORKLOADP/workloada -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloada_load

echo "running workloada" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloada -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloada_run
#workloadb
echo "running workloadb" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadb -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadb_run
echo "running workloadc" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadc -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadc_run
echo "running workloadf" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadf -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadf_run

#workloadd
$MONGOPATH --host $DBURL --eval "db.getSiblingDB('ycsb').dropDatabase()"
echo "loading workloadd" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP load mongodb -P $WORKLOADP/workloadd -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadd_load
echo "running workloadd" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadd -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadd_run
#workloade
$MONGOPATH --host $DBURL --eval "db.getSiblingDB('ycsb').dropDatabase()"
echo "loading workloade" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP load mongodb -P $WORKLOADP/workloade -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloade_load
echo "running workloade" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloade -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloade_run
