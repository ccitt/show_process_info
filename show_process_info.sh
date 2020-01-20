#!/bin/bash
# Summarizes and displays cpu usage,physical memory and swap usage information for the specified process name
# Licensed ( http://www.apache.org/licenses/LICENSE-2.0 )
# Version: 0.1b
#
# parameter specification
#   $1: Specify the name of the process
#
# use example:
#   show_process_info.sh mysqld
#
# author:	james.zhang
# email:	ccitt@tom.com
# last change time: 2020-01-20

CurrentUser=$(env | grep -w "USER" | cut -d "=" -f 2)
if [ "$CurrentUser" != 'root' ];
then
	echo "show_process_info.sh script requires root privileges to execute normally, Please switch to root user and try again!";
    exit 2
fi

#Get all mysql process idsport="$1"
ProcessName="$1"
if [ -z "$ProcessName" ]
then
	ProcessName='mysqld';
fi

PIDS=$(pidof $ProcessName);

#Detect for mysql process id
num=${#PIDS[*]};
if [ "$num" = 0 ];
then
	echo -e "\nNo search to $ProcessName process!";
else
	echo -e "\nStart counting each $ProcessName Process Physical Memory AND Swap Usage Information ......\f";
fi

#Find all Port Info by PIDS
PID_STR=$(echo "${PIDS[*]}" | tr ' ' '|');
AllPortInfo=$(ss -tnlp | grep -E "${PID_STR}" | awk '{print $4,$6};' | tr '\n' '|' | tr ' ' '&');

#Get information for each process
for ((i=0; i<"$num"; i++))
do
	#Find Port by process id
	Port=$(echo "${AllPortInfo}" | tr '|' '\n' | tr '&' ' ' | grep "${PIDS[$i]}" | awk '{print $1};');

	#smapsMemoryInfo=(`grep Pss /proc/${PIDS[$i]}/smaps | awk '{total+=$2}; END {print total/1024 "MB"}'`);
	MemoryInfo=$(grep -E "VmHWM|VmRSS|VmSwap" /proc/"${PIDS[$i]}"/status | awk '{print $2/1024 "MB"};');
	CpuUsageInfo=$(ps  -eLo pid,lwp,pcpu | grep "${PIDS[$i]}" | awk '{total+=$3}; END {print total "%"}');
	echo -e "$ProcessName PROCESS ID:\e[1;31m${PIDS[$i]}\e[0m Port \e[1;34m${Port:3}\e[0m Instance Information:";
	echo -e "Cpu usage: ${CpuUsageInfo}";
	echo -e "Current Used Physical Memory: ${MemoryInfo[1]}";
	echo -e "Used Maximum Physical Memory: ${MemoryInfo[0]}";
	echo -e "Used Swap: ${MemoryInfo[2]} \f";
done