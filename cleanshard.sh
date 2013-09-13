#!/bin/bash

SM_PATH=./shardmachine.sh
#CONF_PATH=/mnt/workspace/YCSBScripts/shardconf.sh
CONF_PATH=./shardconf.sh
. $CONF_PATH

#first, kill + clean existing locations
pgrep mongo | xargs sudo kill

#first we remove old files
rm -rf $BASE_DATA_PATH/*
rm -rf $BASE_LOG_PATH/*
rm -rf $BASE_DUR_PATH/*

#next call shardmachine with appropriate options
$SM_PATH
