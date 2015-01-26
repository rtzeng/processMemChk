#!/usr/bin/env python
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
# Usage: check_proc_mem.py [-l low_limit] [-h high_limit] [--help]
#        -l, --low   => optional-lower limit memory in GB (10 default)
#        -h, --high  => optional-higher limit memory in GB (15 default)
#        --help      => prints usage
#
#        examples:  ./check_proc_mem.py
#                   ./check_proc_mem.py -l 8
#                   ./check_proc_mem.py -l 8 -h 12
#                   ./check_proc_mem.py --help
#                                                                              #

import os, sys, getopt

# function for usage
def usage(message):
    # print out error message passed to function
    print "ERROR: %s" % (message)
    print "Usage: check_proc_mem.py [-l low_limit] [-h high_limit] [--help]"
    print "Options:"
    print "-l, --low  => optional-lower limit memory in GB (10 default)"
    print "-h, --high => optional-higher limit memory in GB (15 default)"
    print "--help     => print usage"
    sys.exit(3)

# function to check server memory against default and/or defined limits
def server_mem_chk(limit):
    # find out how much memory on server in kB
    total = os.popen("head -1 /proc/meminfo | awk '{print $2}'").read().strip()

    # check to see if limits exceed server physical memory
    if int(limit) > int(total):
        usage("Server has %s kB of RAM" % (total))

# function to determine the process memory usage 
def __main__():
    # define default limits in kB
    low_GB = 10
    high_GB = 15
    low_limit = low_GB * 1024 * 1024
    high_limit = high_GB * 1024 * 1024

    # parse through the arguments
    try:
        opts, args = getopt.getopt(sys.argv[1:], "l:h:", ["help", "low=",\
            "high="])
    except getopt.GetoptError:
        usage("check arguments")
        sys.exit(3)

    # parse through arguments
    for options, arguments  in opts:
        if options == "--help":
            usage("You need help! Here's the usage.")
            sys.exit(3)
        elif options in ("-l", "--low"):
            low_GB = int(arguments)
            low_limit = low_GB * 1024 * 1024
            server_mem_chk(low_limit) 
        elif options in ("-h", "--high"):
            high_GB = int(arguments)
            high_limit = high_GB * 1024 * 1024
            server_mem_chk(high_limit) 
        else:
            assert False, "Unknown argument"

    # check to make sure high >= low limit
    if high_limit < low_limit:
        usage("Check argument order") 

    # check to make sure high limit doesn't exceed server physical memory
    server_mem_chk(high_limit)

    # use ps and popen module to sort rss output and loop through proc list  
    for process in os.popen("ps -eo rss=,comm= --sort -rss").read().strip().\
            split("\n"):
        # need to manipulate outpot of os.popen
        proc = process.split()

        # conditional checks of mem usage against limits
        if int(proc[0]) < low_limit:
            # less than the lower limit
            print "OK-no process exceeds %sGB memory usage" % (low_GB)
            sys.exit(0)
        elif int(proc[0]) >= low_limit and int(proc[0]) < high_limit:
            # greater/EQUAL to low or less than but not equal to high limit
            print "WARNING-process %s between %s-%sGB usage" % (proc[1],\
                low_GB, high_GB)
            sys.exit(1)
        else:
            # mem_num not true for above so EQUAL/greater than high limit
            print "CRITICAL-process %s equal or exceeds %sGB usage" % \
                (proc[1], high_GB)
            sys.exit(2)


### MAIN SECTION ###
if __name__ == '__main__':
    __main__()
