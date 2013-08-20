#!/bin/bash

DBPATH="/mnt/ebs/data/"
LOGPATH="/mnt/ebs/data/log"
JPATH="/mnt/dur/"
#MDPATH="/home/ec2-user/mongodb-linux-x86_64-2.4.4/bin/mongod"
MDPATH="/home/ec2-user/tokumx/bin/mongod"
JLINK=$DBPATH"journal"

pgrep mongo | xargs sudo kill

#first we remove old files
rm -rf $DBPATH
mkdir $DBPATH
rm $LOGPATH

rm -rf $JPATH*
sudo ln -s $JPATH $JLINK

#next we turn on mongod
#$MDPATH --dbpath $DBPATH --logpath $LOGPATH --fork 
numactl --interleave=all $MDPATH --dbpath $DBPATH --logpath $LOGPATH --fork 
echo 0 > /proc/sys/vm/zone_reclaim_mode
