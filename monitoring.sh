#!/bin/bash

ARCH=$(uname -a)
PCPU=$(lscpu | grep Socket | awk {'print $2'})
VCPU=$(lscpu | grep 'CPU(s):' | head -1 | awk {'print $2'})
#VCPU=$(cat /proc/cpuinfo | grep processor | wc -l)
TMEM=$(free -m | grep Mem | awk {'printf "%d", $2'})
#FMEM=$(free -m | grep Mem | awk {'printf "%d", $4'})
#UMEM=$(($TMEM - $FMEM))
UMEM=$(free -m | grep Mem | awk {'printf "%d", $3'})

MEM_PR=$(free -m | grep Mem | awk {'printf "%.2f", (($2 - $4) * 100)/ $2'})

TDISK=$(df --total -h | grep total | awk {'printf "%.2f" ,$2'})
UDISK=$(df --total -h | grep total | awk {'printf "%.2f" ,$3'})
DISK_PR=$(df --total -h | grep total | awk {'print $5'})

CPULOAD=$(mpstat | awk {'print $13'} | tail -1 | awk {'printf "%.1f",100 - $1'})

LVM_COND=$(lsblk | grep lvm | wc -l)
LVM_STATUS=0
if [ $LVM_COND == 0 ] ; then
	LVM_STATUS="no"
else
	LVM_STATUS="yes"
fi
USERLOG=$(who | wc -l)
#SUDO=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
BOOT=$(who -b | awk {'print $3" "$4'})
SUDO=$(cat /var/log/sudo/logfile.log | grep COMMAND | wc -l)
#IP=$(ifconfig | grep "inet" | head -1 | awk '{print $2}')
IP=$(hostname -I)
MAC=$(ifconfig | grep "ether" | head -1 | awk '{print $2}')
#CONNECTIONS=$(netstat | grep tcp | grep ESTABLISHED | wc -l)
CONNECTIONS=$(ss --tcp | grep ESTAB | wc -l)
wall "
	#Architecture: : $ARCH
	#CPU physical : $PCPU
	#vCPU : $VCPU
	#Memory Usage: $UMEM/$TMEM MB ($MEM_PR%)
	#Disk Usage: $UDISK/$TDISK GB ($DISK_PR)
	#CPU load: $CPULOAD %
	#Last boot: $BOOT
	#LVM use: $LVM_STATUS
	#Connections TCP: $CONNECTIONS ESTABLISHED
	#User log: $USERLOG
	#Network: IP $IP ($MAC)
	#Sudo : $SUDO cmd
"