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
ports_gen ()
{
	echo "        - starting ${PORTSFILE}"
	for LISTENIP in `echo ${WORKINGSERVER} | cut -f 3 -d : | sed s/-/\ /g | sed s/\;/\:/g`
	do
		for PORTS in `grep ^P ${STRIPCONF}`
		do
			PORT=`echo ${PORTS} | cut -f 2 -d :`
			OPTIONS=`echo ${PORTS} | cut -f 3 -d :`
			if [ `echo "${LISTENIP}"| grep -c ^\\\[` = "0" ] ; then
				echo "listen [::ffff:${LISTENIP}]:${PORT} {" >> ${PORTSFILE}
			else
				echo "listen ${LISTENIP}:${PORT} {" >> ${PORTSFILE}
			fi
			if [ "${OPTIONS}" != "" ] ; then
				echo "        options {" >> ${PORTSFILE}
				case ${OPTIONS} in *c*) echo "                clients-only;" >> ${PORTSFILE} ;;	esac
				case ${OPTIONS} in *s*) echo "                servers-only;" >> ${PORTSFILE} ;;	esac
				case ${OPTIONS} in *l*) echo "                ssl;" >> ${PORTSFILE} ;;		esac
				echo "        };" >> ${PORTSFILE}
			fi
			echo "};" >> ${PORTSFILE}
		done
	done
	echo "        - ending ${PORTSFILE}"
}
