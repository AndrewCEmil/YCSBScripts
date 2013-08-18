h is for doing the complete fusionIO performance testing.  It breaks into a few
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

CLEANDBP=$1
OUTDIR=$2

#1) Initialization and command line parsing
DBURL="10gencasvr.local"
KEYP="/home/ace/10gencasvr_root_key"
YCSBP="/home/ace/YCSB/bin/ycsb"
WORKLOADP="/home/ace/workloads"
#a file for the recordcount and operation count
WORKLOADCOUNTP="/home/ace/workloads/counts"
USRNAME="ace"
NUMTHREADS="100"
rm -rf $OUTDIR/*
mkdir $OUTDIR

#3) Instrumenting systems
ssh -i $KEYP root@$DBURL mpstat -P ALL 1 > $OUTDIR/mpstat &
MPSTATPID=$!
ssh -i $KEYP root@$DBURL iostat -t -d -x -h 1 > $OUTDIR/iostat &
IOSTATPID=$!

#4) actual testing
#workloada
ssh -i $KEYP root@$DBURL $CLEANDBP
ssh -i $KEYP root@$DBURL mongostat >> $OUTDIR/mongostat &
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
ssh -i $KEYP root@$DBURL $CLEANDBP
ssh -i $KEYP root@$DBURL mongostat >> $OUTDIR/mongostat &
echo "loading workloadd" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP load mongodb -P $WORKLOADP/workloadd -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadd_load
echo "running workloadd" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloadd -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloadd_run
#workloade
ssh -i $KEYP root@$DBURL $CLEANDBP
ssh -i $KEYP root@$DBURL mongostat >> $OUTDIR/mongostat &
echo "loading workloade" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP load mongodb -P $WORKLOADP/workloade -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloade_load
echo "running workloade" >> $OUTDIR/runout
echo `date` >> $OUTDIR/runout
$YCSBP run mongodb -P $WORKLOADP/workloade -P $WORKLOADCOUNTP -threads $NUMTHREADS > $OUTDIR/workloade_run

#5) cleanup
kill $MPSTATPID
kill $IOSTATPID
