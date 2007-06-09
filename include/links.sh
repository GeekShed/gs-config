# Copyright (c) 2005-2007  WyldRyde IRC Network
# All rights reserved.
#
# $Id$
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
# SUCH DAMAGE
links_gen ()
{
	LINKFILE=${CONFPATH}/links.conf
	echo "\t- starting ${LINKFILE}"
	MYREGION=`grep ^S ${STRIPCONF} | grep ${SERVERNAME} | cut -d : -f 8`
	for REMOTESERVER in `grep ^S ${STRIPCONF} | grep -v ${SERVERNAME}`
	do
		LINKNAME=`echo ${REMOTESERVER} | cut -f 2 -d :`
		LINKIP=`echo ${REMOTESERVER} | cut -f 3 -d : | cut -f 1 -d -`
		REGION=`echo ${REMOTESERVER} | cut -f 8 -d :`
		OPTIONS=`echo ${REMOTESERVER} | cut -f 5 -d :`
		echo "link ${LINKNAME}.${NETWORK} {" >> ${LINKFILE}
		echo "\tusername *;" >> ${LINKFILE}
		echo "\thostname ${LINKIP};" >> ${LINKFILE}
		echo "\tbind-ip ${BINDIP};" >> ${LINKFILE}
		echo "\tport 4400;" >> ${LINKFILE}
		echo "\tpassword-connect \"wyldryde-l33t-link-password\";" >> ${LINKFILE}
		echo "\tpassword-recieve \"\$MMeriLxK\$lVYlZHHBGNvcZcZEBw1d/w==\" { md5; };" >> ${LINKFILE}
		ISAHUB=0
		ISMYHUB=0
		for HLINES in `grep ^H ${STRIPCONF}`
		do
			if [ `echo ${HLINES} | cut -d : -f 4` = "${LINKNAME}" ]; then
				ISAHUB=1
				if [ `echo ${HLINES} | cut -d : -f 2` = "${MYREGION}" ]; then
					#this server is the hub for HUBREGION, and MYREGION is HUBREGION so this is my hub
					ISMYHUB=1
				fi
			fi
		done
		if [ "${ISAHUB}" = "1" ]; then
			if [ `grep ^H:0 ${STRIPCONF} | cut -d : -f 4` = "${LINKNAME}" ]; then
				#this server is the root hub
				echo "\tclass roothub;" >> ${LINKFILE}
			else
				echo "\tclass hub;" >> ${LINKFILE}
			fi
			echo "\thub *;" >> ${LINKFILE}
			echo "\toptions {" >> ${LINKFILE}
			if [ "${ISMYHUB}" = "1" ]; then
				echo "\t\tautoconnect;" >> ${LINKFILE}
			fi
			case ${OPTIONS} in *s*) echo "\t\tssl;" >> ${LINKFILE} ;;	esac
			case ${OPTIONS} in *z*) echo "\t\tzip;" >> ${LINKFILE} ;;	esac
			echo "\t};" >> ${LINKFILE}
		else
			echo "\tclass leaf;" >> ${LINKFILE}
			echo "\thub *;" >> ${LINKFILE}
			echo "\toptions {" >> ${LINKFILE}
			if [ `grep ^H:${REGION} ${STRIPCONF} | cut -d : -f 4` = "${SERVERNAME}" ]; then
				#i am the hub for this region
				#reverse autoconnect
				case ${OPTIONS} in *a*) echo "\t\tautoconnect;" >> ${LINKFILE} ;;	esac
			fi
			case ${OPTIONS} in *s*) echo "\t\tssl;" >> ${LINKFILE} ;;	esac
			case ${OPTIONS} in *z*) echo "\t\tzip;" >> ${LINKFILE} ;;	esac
			case ${OPTIONS} in *q*) echo "\t\tquarantine;" >> ${LINKFILE} ;;	esac
			echo "\t};" >> ${LINKFILE}
		    fi
		    echo "};" >> ${LINKFILE}
	done
	echo "\t- ending ${LINKFILE}"
}

