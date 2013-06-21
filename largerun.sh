#!/bin/bash

#the goal here is to run a series of ycsb tests with resets on the db everytime

#assumptions:
#-DB has the cleandb.sh in the home directory
#-Client has ycsbrun.sh and ycsbparser in home directory
#-Both machines do not require tty for sudo (turn off in /etc/sudoers)

CLIENTURL="ec2-50-112-40-236.us-west-2.compute.amazonaws.com"
#DBURL="ec2-54-214-150-65.us-west-2.compute.amazonaws.com"
DBURL="ec2-54-214-86-242.us-west-2.compute.amazonaws.com"
KEYP="/Users/ace/perftesting/keys/acekeys.pem"
OUTPATH="/Users/ace/perftesting/testouts/bigtestclean.log"

CLEANDBP="/home/ec2-user/cleandb.sh"


echo "start" > $OUTPATH
#clean the excess files
ssh -i $KEYP ec2-user@$CLIENTURL rm -f loadout*
ssh -i $KEYP ec2-user@$CLIENTURL rm -f testout*

#loop + run ycsb tests + save output 
for i in {1..10}
do
    #First clean/restart the database 
    ssh -i $KEYP ec2-user@$DBURL sudo $CLEANDBP
    #Next start the client with the new number
    ssh -i $KEYP ec2-user@$CLIENTURL sudo /home/ec2-user/ycsbrun.sh $i
    #finally append the output to the output file
    echo $i >> $OUTPATH
    ssh -i $KEYP ec2-user@$CLIENTURL python /home/ec2-user/ycsbparser.py $i >> $OUTPATH
done
