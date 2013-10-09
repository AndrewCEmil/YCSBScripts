#!/bin/bash.sh
set -x

uname -a
lscpu
lsblk
lspci
cat /proc/meminfo
ifconfig
hdparm /dev/sda
hdparm -i /dev/sda
dmidecode --type memory
cat /proc/cpuinfo
