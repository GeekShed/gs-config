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
	SOPTIONS="$(echo ${WORKINGSERVER} | cut -f 5 -d :)"

	case "${SOPTIONS}" in
		*o*)
			SSLONLY="yes"
		;;
		*t*)
			SCTPENABLED="yes"
		;;
		*p*)
			PRIVATEIP="yes"
		;;
	esac

	for PORTS in $(grep ^P: ${STRIPCONF})
	do
		PORT="`echo ${PORTS} | cut -f 2 -d :`"
		OPTIONS="`echo ${PORTS} | cut -f 3 -d :`"
		POSTFIX=""
		# If p set, don't listen on first IP
		if [ "${PRIVATEIP}" = "yes" ] ; then
			LISTENIPS="$(echo "${WORKINGSERVER}" | cut -f 3 -d : | cut -f 2- -d - | sed s/-/\ /g)"
		else
			LISTENIPS="$(echo "${WORKINGSERVER}" | cut -f 3 -d : | sed s/-/\ /g)"
		fi

		case "${OPTIONS}" in
			*t*)
				SCTPPORT="yes"
			;;
		esac
		case "${OPTIONS}" in
			*l*)
				POSTFIX="${POSTFIX} ssl"
			;;
		esac
		case "${OPTIONS}" in
			*q*)
				POSTFIX="${POSTFIX} seqpacket"
			;;
		esac
		case "${OPTIONS}" in
			*c*)
				POSTFIX="${POSTFIX} clientsonly"
			;;
		esac
		case "${OPTIONS}" in
			*s*)
				case "${POSTFIX}" in
					*)
						POSTFIX="${POSTFIX} serversonly"
					;;
				esac
			;;
		esac
		if [ "${SCTPENABLED}" = "yes" -a "${SCTPPORT}" = "yes" ] ; then
			ports_block ANY "${PORT}" sctp "${POSTFIX}" >>${PORTSFILE}

		fi
		for LISTENIP in ${LISTENIPS}
		do
			ports_block ${LISTENIP} "${PORT}" "${POSTFIX}" >>${PORTSFILE}
		done
	done

	echo "    - ending ${PORTSFILE}"
}

ports_block()
{
	CIP="${1}"
	shift
	CPORT="${1}"
	shift

	if [ "${CIP}" = "ANY" ] ; then
		IP="*"
	else
		case "${CIP}" in
			[*)
				IP="$(echo "${CIP}" | sed s/_/:/g)"
			;;
			*)
				IP="${CIP}"
			;;
		esac
	fi

	PORT="${CPORT}"

	if [ "${1}" = "" ] ; then
		echo "listen ${IP}:${PORT};"
	else
		echo "listen ${IP}:${PORT} {"
		echo "    options {"
		for VAR in $*
		do
			case "${VAR}" in
				sctp)
					echo "		sctp;"
				;;
				seqpacket)
					echo "		seqpacket;"
				;;
				ssl)
					echo "		ssl;"
				;;
				serversonly)
					echo "		serversonly;"
				;;
				clientsonly)
					echo "		clientsonly;"
				;;
			esac
		done
		echo "    };"
		echo "};"
	fi
}
