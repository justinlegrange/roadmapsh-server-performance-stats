#!/usr/bin/env bash

# Usage: ./server-stats.sh

VER="0.2.1"

echo -e "\t-=-=-=- SYSTEM STATUS CHECKER V$VER -=-=-=-"

# CPU USAGE
# Calculation from https://linuxvox.com/blog/accurately-calculating-cpu-utilization-in-linux-using-proc-stat/

# Need to get 2 samples for deltas from /proc/sys
# Using cut, delimits cpu info into fields starting from 3
echo "[*] Gathering CPU sample 1..."
CPU_USER_S1=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 3)
CPU_USER_NICE_S1=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 4)
CPU_SYS_S1=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 5)
CPU_IDLE_S1=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 6)
CPU_IO_S1=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 7)
CPU_IRQ_S1=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 8)
CPU_SIRQ_S1=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 9)
CPU_STEAL_S1=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 10)
sleep 1
echo "[*] Gathering CPU sample 2..."
CPU_USER_S2=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 3)
CPU_USER_NICE_S2=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 4)
CPU_SYS_S2=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 5)
CPU_IDLE_S2=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 6)
CPU_IO_S2=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 7)
CPU_IRQ_S2=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 8)
CPU_SIRQ_S2=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 9)
CPU_STEAL_S2=$(cat /proc/stat | grep '^cpu ' | cut -d ' ' -f 10)

# Compute the change over the delta:
DELTA_USER=$(($CPU_USER_S2 - $CPU_USER_S1))
DELTA_NICE=$(($CPU_USER_NICE_S2 - $CPU_USER_NICE_S1))
DELTA_SYS=$(($CPU_SYS_S2 - $CPU_SYS_S1))
DELTA_IDLE=$(($CPU_IDLE_S2 - $CPU_IDLE_S1))
DELTA_IOWAIT=$(($CPU_IO_S2 - $CPU_IO_S1))
DELTA_IRQ=$(($CPU_IRQ_S2 - $CPU_IRQ_S1))
DELTA_SIRQ=$(($CPU_SIRQ_S2 - $CPU_SIRQ_S1))
DELTA_STEAL=$(($CPU_STEAL_S2 - $CPU_STEAL_S1))

# Calculate jiffies, excluding IOwait.
TOTAL_JIFFIES=$(($DELTA_USER+$DELTA_NICE+$DELTA_SYS+$DELTA_IDLE+$DELTA_IRQ+$DELTA_SIRQ+$DELTA_STEAL))
IDLE_JIFFIES=$DELTA_IDLE

# Calculate CPU usage.
BUSY_JIFFIES=$(($TOTAL_JIFFIES-$IDLE_JIFFIES))
CPU_USAGE=$(echo "scale=5;$BUSY_JIFFIES/$TOTAL_JIFFIES*100" | bc)

# MEMORY USAGE
MEM_USED=$(free -m | awk '/Mem/{print $3}')
MEM_TOTAL=$(free -m | awk '/Mem/{print $2}')
# MEM_PERCENT=(($MEM_USED/$MEM_TOTAL)*100)
MEM_PERCENT=$(echo "scale=5;$MEM_USED/$MEM_TOTAL*100" | bc)
SWAP_USED=$(free -m | awk '/Swap/{print $3}')
SWAP_TOTAL=$(free -m | awk '/Swap/{print $2}')
# SWAP_PERCENT=(($SWAP_USED/$SWAP_TOTAL)*100)
SWAP_PERCENT=$(echo "scale=5;$SWAP_USED/$SWAP_TOTAL*100" | bc)

echo -e "\nCPU Usage Stats (All CPUs)"
printf "%s\n" "[*] Usage: $CPU_USAGE%"
echo -e "\nDisk Usage Stats (All Disks)"
df -lh | grep -v "Use"
echo -e "\nMemory Usage %"
printf "%s\n" "[*] Memory Used: $MEM_PERCENT%"
printf "%s\n" "[*] Swap Used: $SWAP_PERCENT%"
echo -e "\nMemory Usage (All)"
free -h
