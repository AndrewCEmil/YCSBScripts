#!/bin/bash
#note that this takes an arg that is the outfiles suffix

LOADNAME="/home/ec2-user/loadout"$1
TESTNAME="/home/ec2-user/testout"$1

/home/ec2-user/YCSB/bin/ycsb load mongodb -P /home/ec2-user/workloada -threads 100 >> $LOADNAME
/home/ec2-user/YCSB/bin/ycsb run mongodb -P /home/ec2-user/workloada -threads 100 >> $TESTNAME
