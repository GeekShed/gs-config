#!/bin/bash

dir=/home/wamphyre/gs-config

cd $dir

cat conf/network.conf| grep ^S | cut -d : -f 2 | while read line; do echo $line ; ossh $line "crontab -l"; done
