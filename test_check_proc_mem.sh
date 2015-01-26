#!/bin/bash
# Author: Richard Tzeng
# Date: 01/25/2015
# Inputs: none
# Outputs: testing status
#
# Notes: this test script needs to be run from the same directory as the
#        check_proc_mem.sh and check_proc_mem.py scripts. 

# run scripts to check argument limits, exit codes, and print ok or bad

# function to run through the arguments

low=( "0" "1" "1" "8" "10" "11" "15" "20" "100" "" "" "" "16" "14" "8" "17" )
high=( "0" "1" "2" "9" "12" "13" "16" "24" "200" "16" "14" "8" "" "" "" "14" )

for (( i = 0; i < ${#low[@]} ; i++ )); do
    printf '=%.0s' {1..75}
    echo -e "\nchecking these values -l ${low[$i]} -h ${high[$i]}"
    printf '=%.0s' {1..75}
    echo
    ./check_proc_mem.sh -l ${low[$i]} -h ${high[$i]}
    echo "^^^ $? bash -l -h ###"
    ./check_proc_mem.py -l ${low[$i]} -h ${high[$i]}
    echo "^^^ $? python -l -h ###"
    ./check_proc_mem.sh --low ${low[$i]} --high ${high[$i]}
    echo "^^^ $? bash --low --high ###"
    ./check_proc_mem.py --low ${low[$i]} --high ${high[$i]}
    echo "^^^ $? python --low --high ###"
    printf '=%.0s' {1..40}
    echo
    ./check_proc_mem.sh -l ${low[$i]}
    echo "^^^ $? bash -l ###"
    ./check_proc_mem.py -l ${low[$i]}
    echo "^^^ $? python -l ###"
    ./check_proc_mem.sh -h ${low[$i]}
    echo "^^^ $? bash -h ###"
    ./check_proc_mem.py -h ${low[$i]}
    echo "^^^ $? python -h ###"
done

# other checks
./check_proc_mem.sh --help
echo "^^^ $? bash help ###"
./check_proc_mem.py --help
echo "^^^ $? python help ###"
./check_proc_mem.sh --jibjab
echo "^^^ $? bash bad arg ###"
./check_proc_mem.py --jibjab
echo "^^^ $? pythong bad arg ###"    
