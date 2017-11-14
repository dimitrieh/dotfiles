#!/bin/bash
num1=$(/usr/local/bin/docker ps | wc -l);
num2=1
echo "$(($num1-$num2)) ⎈"
echo "---";
/usr/local/bin/docker ps
