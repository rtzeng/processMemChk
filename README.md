Check Process Memory
====================

Description
-----------

These scripts scan the process list for any process that exceeds the default or
defined memory limits.  The limits are defined below: 
  1. exits status code 0 if no process exceeds 10G
  2. exits status code 1 if a process equals or exceeds 10G but less than 15G
  3. exits status code 2 if a process equals of exceeds 15G
  4. in the case of (2) and (3), also return the offending process name

The process memory check will use the ps command and sort using the resident
set size. RSS doesn't include swap but include in its calculation the memory
that is shared with other processes. Linux loads libraries once into memory.
If multiple processes use the same library, then the acutal memory usage will
be smaller if you subtract the shared memory of the library. It's debateable
whether the ps command will produce accurate results. However, with many
monitoring alerts, investigation of why the alert was triggered is always
necessary. Therefore, if a critical alert is triggered, one will need to 
verify that the process is indeed using an absorbent amount of memory. One can
use the "pmap -d|-x PID" command to further drill down into the memory mapping
to see if the identified process is indeed exceeding the monitoring limit.

The default limits are 10GB for the lower limit and 15GB for the higher limit.
An option to change the limits can be passed to the scripts. While testing the
scripts on machines with less than 15 GB of RAM, the results produced a false
negative in that the reported memory usage would never reach the high limit of
15 GB. Thus, the decision to include options to define the low and high limit
based on the server being used. This also makes the script convenient to run on
a variety of machines with different RAM sizes.


Downloading
-----------

The scripts are available on github.com.  This README is also available on 
github.com to get usage information.

  https://github.com/rtzeng/processMemChk.git


Installation
------------

Once downloaded or cloned onto a Linux machine, make sure the scripts are
executable.  

System Specific Notes
---------------------

These scripts were tested on the following machines:
  * RHEL 5.9 and 5.11 using python version 2.4.3 and 2.6 respectively
  * RHEL 6.6 using python version 2.6.6
  * Ubuntu 14.04.1 LTC using python version 2.7.6

The scripts have not been tested on OSX nor using python version 3.X. One would
need to convert a few the python print commands and bash ps commands if wanting
to run on a MAC or using python 3.X.

tl;dr
