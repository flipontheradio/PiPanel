#!/bin/bash

echo "Cusor check is running"

# ---- Global variables ----
path=$(grep -A 2 "FT5406 memory based driver" /proc/bus/input/devices | grep -v "FT5406 memory based driver" | grep -v "Phys")
input=/dev/input/event${path#*/input/input}
code_prefix="ABS"
code1="${code_prefix}_[X]"
code2="${code_prefix}_[Y]"
val_regex=".*(${code_prefix}_\(.\)), value \([-]\?[0-9]\+\)"
val_subst="\2"

#create inital file with zero variables
echo 0 > /home/pi/Documents/cursorXPos.txt

# ---- Functions ----
send_axis() {
    xy="$1$2"
    echo "$1$2" > /home/pi/Documents/cursorXPos.txt
}

process_line() {
    while read line1; do
        axisa=$(echo $line1 | grep "^Event:" | grep $code1 | \
               sed "s/$val_regex/$val_subst/")
        axisb=$(echo $line1 | grep "^Event:" | grep $code2 | \
               sed "s/$val_regex/$val_subst/")
        if [ -n "$axisa" ] ; then
            X="$axisa"
        fi
        if [ -n "$X" ] && [ -n "$axisb" ] ; then
           send_axis $X $axisb
           X=""
        fi
    done
}

# ---- Entry point ----

if [ $(id -u) -ne 0 ]; then
    echo "This script must be run from root" >&2
    exit 1
fi

evtest $input | process_line
