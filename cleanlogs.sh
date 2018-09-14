#! /bin/bash

# cleaning all log files
echo "---> *.log files found"
find find . -name "*.log" -type f
find . -name "*.log" -type f -delete
# cleaning all nohup files
echo "---> nohub.out files found"
find . -name "nohup.out" -type f
find . -name "nohup.out" -type f -delete
