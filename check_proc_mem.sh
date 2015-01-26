#!/bin/bash
# Author: Richard Tzeng
# Date:  01/25/2015
# Description:  This script checks for any processes that are using
#               greater than the defined limits.
#
# Inputs: [optional] low and high limit in GB, default is 10 GB low limit
#         and 15 GB high limit
#
# Outputs: the script will output the following
#          1. ok (exit 0) if no process memory exceeds the low limit
#          2. warning (exit 1) if process memory is equal to the low limit
#             or between the low and high limit
#          3. critical (exit 2) if process memory equals/exceeds high limit
#          4. help (exit 3) to print the usage
#
# Note:  The process memory check will use the ps command and sort using the 
#        resident set size. RSS doesn't include swap and doesn't take into
#        account the memory that is shared with other processes.
#
# Usage: check_proc_mem.sh [-l low_limit] [-h high_limit] [--help]
#        -l, --low   => optional-lower limit memory in GB (10 default)
#        -h, --high  => optional-higher limit memory in GB (15 default)
#        --help      => prints usage
#
#        examples:  ./check_proc_mem.sh
#                   ./check_proc_mem.sh -l 8
#                   ./check_proc_mem.sh -l 8 -h 12
#                   ./check_proc_mem.sh --help
#                                                                              #

# function for usage
usage () {
    # print out error message passed to function
    echo "ERROR: $1"
    echo "Usage: check_proc_mem.sh [-l low_limit] [-h high_limit] [--help]"
    echo "Options:"
    echo "-l, --low  => optional-lower limit memory in GB (10 default)"
    echo "-h, --high => optional-higher limit memory in GB (15 default)"
    echo "--help     => print usage"
    exit 3
}

# function to check server memory against default and/or defined limits
server_mem_chk () {
    # find out how much memory on server in kB
    total_mem=$(head -1 /proc/meminfo | awk '{print $2}')

    # check to see if limit exceed server physical memory
    if [ $1 -gt ${total_mem} ]; then
        usage "Server has ${total_mem}kB of RAM"
    fi
}

## MAIN ##
# define default limits in kB
low_GB=10
high_GB=15
low_limit=$(( ${low_GB} * 1024 * 1024 ))
high_limit=$(( ${high_GB} * 1024 * 1024 ))

# checks for arguments and total memory, assign new variables
while test -n "$1"; do
    case "$1" in
        --help)
            usage
            exit 1
            ;;
        --low|-l)
            low_GB=$2
            low_limit=$(( ${low_GB} * 1024 * 1024 ))
            server_mem_chk ${low_limit}
            shift
            ;;
        --high|-h)
            high_GB=$2
            high_limit=$(( ${high_GB} * 1024 * 1024 ))
            server_mem_chk ${high_limit}
            shift
            ;;
        *)
            usage "Unknown argument"
            exit 3
            ;;
    esac
    shift
done

# check to make sure high >= low limit
[ ${high_limit} -lt ${low_limit} ] && usage "Check argument order"

# check server memory against limits
server_mem_chk ${high_limit}

# using ps, sort rss and output format to loop through proc list
ps -eo rss=,comm= --sort -rss | while read line; do
    # assign variables to mem usage and proc name
    mem_num=$(echo ${line} | awk '{print $1}')
    ps_name=$(echo ${line} | awk '{print $2}')

    # conditional checks of mem usage against limits
    if [ ${mem_num} -lt ${low_limit} ]; then
        # less than the lower limit
        echo "OK-no process exceeds ${low_GB}GB memory usage"
        exit 0
    elif [ ${mem_num} -ge ${low_limit} -a ${mem_num} -lt ${high_limit} ]; then
        # greater/EQUAL to the lower or less than but not equal to high limit
        echo "WARNING-process ${ps_name} between ${low_GB}-${high_GB}GB usage"
        exit 1
    else
        # mem_num not true for any of above so EQUAL/greater than high limit
        echo "CRITICAL-process ${ps_name} equal or exceeds ${high_GB}GB usage"
        exit 2
    fi
done
