#!/usr/bin/env bash
#
# Portions Copyright (c) 2005-2007  WyldRyde IRC Network
# Copyright (c) 2009 GeekShed Ltd.
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
	PORTSFILE=${CONFPATH}/ports.conf
	echo "    - starting ${PORTSFILE}"
	for LISTENIP in `echo ${WORKINGSERVER} | cut -f 3 -d : | sed s/-/\ /g | sed s/\;/\:/g`
	do
		unset SCTPENABLED
		unset SSLONLY
		SOPTIONS="$(echo ${WORKINGSERVER} | cut -f 5 -d :)"
		case "${SOPTIONS}" in
			*o*)
				SSLONLY="yes"
			;;
			*t*)
				SCTPENABLED="yes"
			;;
			*)
				unset SSLONLY
			;;
		esac

		for PORTS in `grep ^P: ${STRIPCONF}`
		do
			unset SCTPPORT
			PORT="`echo ${PORTS} | cut -f 2 -d :`"
			OPTIONS="`echo ${PORTS} | cut -f 3 -d :`"
			case "${OPTIONS}" in
				*t*)
					SCTPPORT=yes
				;;
			esac
			case "${OPTIONS}" in
				*l*)
					USEPORTS=yes
				;;
				*s*)
					USEPORTS=yes
				;;
				*t*)
					USEPORTS=yes
				;;
				*)
					unset USEPORTS
				;;
			esac
			echo "${LISTENIP}"
			if [ "${SSLONLY}" = "" -o "${USEPORTS}" != "" ] ; then
				if [ "${SCTPPORT}" = "yes" ] ; then
					if [ "${SCTPENABLED}" != "yes" ] ; then
						continue
					fi
				fi
				if [ "$(echo "${LISTENIP}"| grep -c ^\\\[)" = "0" ] ; then
					echo "listen ${LISTENIP}:${PORT} {" >> ${PORTSFILE}
				else
					echo "listen ${LISTENIP}:${PORT} {" | tr '_' ':' >> ${PORTSFILE}
				fi
				if [ "${OPTIONS}" != "" ] ; then
					echo "    options {" >> ${PORTSFILE}
					case ${OPTIONS} in *c*) echo "        clientsonly;" >> ${PORTSFILE} ;;	esac
					case ${OPTIONS} in *s*) echo "        serversonly;" >> ${PORTSFILE} ;;	esac
					case ${OPTIONS} in *l*) echo "        ssl;" >> ${PORTSFILE} ;;		esac
					case ${OPTIONS} in *t*) echo "        sctp;" >> ${PORTSFILE} ;;		esac
					echo "    };" >> ${PORTSFILE}
				fi
				echo "};" >> ${PORTSFILE}
			fi
		done

	done
	SCTPENABLED="no"
	SCTPPORT="no"

	echo "    - ending ${PORTSFILE}"
}
