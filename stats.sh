#!/bin/bash
# Script to publish CPu, MEMORY, Open File Descriptor, bytes recived and transmitted.


divider===============================
divider=$divider$divider

header="\n %-8s %-10s %-10s %-10s %-10s\n"
format=" %-8s %-10s %-10s %-10s %-10s\n"
width=50
printf  "$header" "CPU" "MEM" "OFILE" "RKBPS" "TKBPS"
printf "%$width.${width}s\n" "$divider"

PREV_TOTAL=0
PREV_IDLE=0

while true; do
R1=`cat /sys/class/net/eth0/statistics/rx_bytes`
T1=`cat /sys/class/net/eth0/statistics/tx_bytes`
sleep 1
# Get the total CPU statistics, discarding the 'cpu ' prefix.
CPU=(`sed -n 's/^cpu\s//p' /proc/stat`)
IDLE=${CPU[3]} # Just the idle CPU time.

# Calculate the total CPU time.
TOTAL=0
for VALUE in "${CPU[@]}"; do
  let "TOTAL=$TOTAL+$VALUE"
done

# Calculate the CPU usage since we last checked.
let "DIFF_IDLE=$IDLE-$PREV_IDLE"
let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"


R2=`cat /sys/class/net/eth0/statistics/rx_bytes`
T2=`cat /sys/class/net/eth0/statistics/tx_bytes`
TBPS=`expr $T2 - $T1`
RBPS=`expr $R2 - $R1`
TKBPS=`expr $TBPS / 1024`
RKBPS=`expr $RBPS / 1024`


MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
OFILE=$(lsof | wc -l)
printf "$format" "$DIFF_USAGE%" "$MEMORY" "$OFILE" "$RKBPS KB/s" "$TKBPS KB/s"

# Remember the total and idle CPU times for the next check.
PREV_TOTAL="$TOTAL"
PREV_IDLE="$IDLE"

done
