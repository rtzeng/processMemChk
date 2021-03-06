Check Process Memory
====================


Description
-----------

These scripts scan the process list for any process that exceeds the default or
defined memory limits.  The limits are defined below: 
  1. exits status code 0 if no process exceeds 10GB
  2. exits status code 1 if a process equals or exceeds 10GB but less than 15GB
  3. exits status code 2 if a process equals or exceeds 15GB
  4. in the case of (2) and (3), also return the offending process name

### A Word About Memory
-----------------------
The process memory check will use the ps command and sort using the Resident
Set Size. RSS doesn't include swap memory but does include the memory
that is shared with other processes. Linux loads libraries into memory one time.
If multiple processes use the same library, then the acutal memory usage will
be smaller when you subtract the library's memory usage. It's debateable
whether the ps command will produce accurate results. However, with many
monitoring alerts, investigation of why the alert was triggered is always
necessary. Therefore, if a critical alert is triggered, one will need to 
verify that the process is indeed using an absorbent amount of memory. One can
use the "pmap -d|-x PID" command to further drill down into the memory mapping
to see if the identified process is indeed exceeding the monitoring limit.

### A Note About Defaults
-------------------------
The default limits are 10GB for the lower limit and 15GB for the higher limit.
An option to change the limits can be passed to the scripts. While testing the
scripts on machines with less than 15 GB of RAM, the results produced a false
negative in that the reported memory usage would never reach the high limit of
15 GB. Thus, the decision was made to include options to define the low and
high limit based on the server's actual configured/installed RAM.


Downloading
-----------

The scripts are available on github.com.

  https://github.com/rtzeng/processMemChk.git


Installation
------------

Once downloaded or cloned onto a Linux machine, make sure the scripts are
executable. Depending on how much memory you have on your machine, one will
need to adjust the low and high limits with the options.


Usage
-----

This is the BASH usage summary. The Python is very similar in usage. If you
leave out any options, the defaults will be used. If your defined lower limit
is higher than the default/defined high limit, then the script will exit with
an error. For example, if you want a lower limit of 20; but the default higher
limit is 15, then the script will exit with an error (20 isn't lower than 15).
machine's RAM in kB. If you leave a limit number out, the script will exit with
an error.

Usage: check_proc_mem.sh [-l low_limit] [-h high_limit] [--help]  
    -l, --low   => optional-lower limit memory in GB (10 default)  
    -h, --high  => optional-higher limit memory in GB (15 default)  
    --help      => prints usage  

       examples:  ./check_proc_mem.sh
                  ./check_proc_mem.sh -l 8
                  ./check_proc_mem.sh --low 8
                  ./check_proc_mem.sh -l 8 -h 12
                  ./check_proc_mem.sh --low 8 --high 12
                  ./check_proc_mem.sh --help

Usage: check_proc_mem.py [-l low_limit] [-h high_limit] [--help]  
     -l, --low   => optional-lower limit memory in GB (10 default)  
     -h, --high  => optional-higher limit memory in GB (15 default)  
     --help      => prints usage  

       examples:  ./check_proc_mem.py
                  ./check_proc_mem.py 8
                  ./check_proc_mem.py --low 8
                  ./check_proc_mem.py -l 8 -h 12
                  ./check_proc_mem.py --low 8 --high 12
                  ./check_proc_mem.py --help


System Specific Notes
---------------------

These scripts were tested on the following machines:
  * RHEL 5.9 and 5.11 using python version 2.4.3
  * CentOS 6.5 and RHEL 6.6 using python version 2.6.6
  * Ubuntu 14.04.1 LTS using python version 2.7.6

The scripts have not been tested on OSX nor using python version 3.X. You would
need to convert a few of the python print cmds and bash ps commands if you
want to run on a MAC or want to use python 3.X.


Testing the Scripts
-------------------

A descending sort of the RSS values from the ps command results in the process
that has the highest memory usage. I coded in a loop to loop through the
process list, but as an enhancement I don't think the loop is needed. This
is though is on the TODO list below.

A script was used to test with various low and high values and few bugs were
identified and corrected. The output of the test script unfortunately is 
cryptic unless you go through what each command is checking. In addition to
testing values, a speed test was conducted between the BASH and python script.
The python script is approximately 40% faster than the BASH script. A small
sample of the time it takes to run each script is given below:

       BASH timed run:
             [rtzeng@hills processMemChk]$ time ./check_proc_mem.sh
             OK-no process exceeds 10GB memory usage
             
             real	0m0.068s
             user	0m0.020s
             sys	0m0.041s
             [rtzeng@hills processMemChk]$

       Python timed run:
             [rtzeng@hills processMemChk]$ time ./check_proc_mem.py
             OK-no process exceeds 10GB memory usage
             
             real	0m0.042s
             user	0m0.014s
             sys	0m0.026s
             [rtzeng@hills processMemChk]$


Bug Reporting and Enhancements
------------------------------

Please report any bugs to <rtzeng@yahoo.com>. Please also contact me if you see
areas for enhancement. The following is a TODO list that I've come up with:
  1. adjust units of limits to MB (both)
  2. bug in empty argument for a single option lower limit (python)
  3. use getopt to parse through BASH options (BASH)
  4. investigate if a loop is needed to look through the process list (both)

tl;dr
