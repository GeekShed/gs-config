#!/bin/bash

dir=/home/wamphyre/gs-config

cd $dir/certs/CA
tar -cvf certs.tar *.crt

cd $dir

cat conf/network.conf| grep ^S | cut -d : -f 2 | while read line; do cat certs/CA/certs.tar | bzip2 | ossh $line "bunzip2 | tar -xpf - -C ./gs-data/gs-ircd/client-certs"; done

rm $dir/certs/CA/certs.tar
