#!/bin/sh
#
# Copyright (c) 2005-2007  WyldRyde IRC Network
# All rights reserved.
#
#	$Id$
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

OUTPUTPATH=/tmp/cf-gen
rm -rf /tmp/cf-gen
mkdir -p /tmp/cf-gen
chmod 750 /tmp/cf-gen
NAME=${CONFIG}

# stripping out comments and whitespace:
grep -v ^# ${NAME} | grep -v ^$ | cut -f 1 -d \# > ${OUTPUTPATH}/network.conf
STRIPCONF=${OUTPUTPATH}/network.conf
mkdir -p ${OUTPUTPATH}/conf
NETWORK=area51

for WORKINGSERVER in `grep ^S ${STRIPCONF}`
do
	SERVERNAME=`echo ${WORKINGSERVER} | cut -f 2 -d :`
	REGION=`echo ${WORKINGSERVER} | cut -f 2 -d :`
	CONFPATH=${OUTPUTPATH}/conf/${SERVERNAME}
	PORTSFILE=${CONFPATH}/ports.conf
	LINKFILE=${CONFPATH}/links.conf
	SERVERFILE=${CONFPATH}/server.conf
	echo "Generating config files for ${SERVERNAME}.${NETWORK}"
	mkdir ${CONFPATH}
	BINDIP=`echo ${WORKINGSERVER} | cut -f 3 -d : | cut -f 1 -d -`
	echo "\t- starting ${LINKFILE}"
	
	for REMOTESERVER in `grep ^S ${STRIPCONF} | grep -v ${SERVERNAME}`
	do
		LINKNAME=`echo ${REMOTESERVER} | cut -f 2 -d :`
		LINKIP=`echo ${REMOTESERVER} | cut -f 3 -d : | cut -f 1 -d -`
		echo "\nlink ${LINKNAME}.${NETWORK} {" >> ${LINKFILE}
		echo "\tusername *;" >> ${LINKFILE}
		echo "\thostname ${LINKIP};" >> ${LINKFILE}
		echo "\tbind-ip ${BINDIP};" >> ${LINKFILE}
		echo "\tport 4400;" >> ${LINKFILE}
		echo "\thub *;" >> ${LINKFILE}
		echo "\tpassword-connect \"wyldryde-l33t-link-password\";" >> ${LINKFILE}
		echo "\tpassword-recieve \"\$MMeriLxK\$lVYlZHHBGNvcZcZEBw1d/w==\" { md5; };" >> ${LINKFILE}
		echo "\tclass leaf;" >> ${LINKFILE}
		echo "\toptions {" >> ${LINKFILE}
		echo "\t};" >> ${LINKFILE}
		echo "};\n" >> ${LINKFILE}
	done
	echo "\t- ending ${LINKFILE}"
	echo "\t- starting ${PORTSFILE}"
	for LISTENIP in `echo ${WORKINGSERVER} | cut -f 3 -d : | sed s/-/\ /g`
	do
		for PORTS in `grep ^P ${STRIPCONF}`
		do
			PORT=`echo ${PORTS} | cut -f 2 -d :`
			OPTIONS=`echo ${PORTS} | cut -f 3 -d :`
			echo "listen ${LISTENIP}:${PORT} {" >> ${PORTSFILE}
			if [ "${OPTIONS}" != "" ] ; then
				echo "\toptions {" >> ${PORTSFILE}
				case ${OPTIONS} in *c*) echo "\t\tclients-only;" >> ${PORTSFILE} ;;	esac
				case ${OPTIONS} in *s*) echo "\t\tservers-only;" >> ${PORTSFILE} ;;	esac
				case ${OPTIONS} in *l*) echo "\t\tssl;" >> ${PORTSFILE} ;;		esac
				echo "\t};" >> ${PORTSFILE}
			fi
			echo "};" >> ${PORTSFILE}
		done
	done
	echo "\t- ending ${PORTSFILE}"
	echo "\t- starting ${SERVERFILE}"
		echo "me {" >> ${SERVERFILE}
		echo "\tname \"${SERVERNAME}.${NETWORK}\";" >> ${SERVERFILE}
		echo "\tinfo \"`echo ${WORKINGSERVER} | cut -f 6 -d :`\";" >> ${SERVERFILE}
		echo "\tnumeric `echo ${WORKINGSERVER} | cut -f 7 -d :`" >> ${SERVERFILE}
		echo "};" >> ${SERVERFILE}
		echo "drpass {" >> ${SERVERFILE}
		echo "\trestart \"`echo ${WORKINGSERVER} | cut -f 8 -d :`\" { sha1; };" >> ${SERVERFILE}
		echo "\tdie \"`echo ${WORKINGSERVER} | cut -f 8 -d :`\" { sha1; };" >> ${SERVERFILE}
		echo "};" >> ${SERVERFILE}
	echo "\t- ending ${SERVERFILE}"

done
