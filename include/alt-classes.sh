#!/usr/bin/env bash
# Portions Copyright (c) 2005-2007  WyldRyde IRC Network
# Copyright (c) 2009 GeekShed Ltd.
# All rights reserved.
#
# $Id: server.sh 234 2010-03-24 19:59:23Z phil@pchowtos.co.uk $
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
altclass_gen ()
{
	SERVERFILE=${CONFPATH}/alt_classes.conf
	echo "    - starting ${SERVERFILE}"
	SLINE=`grep ^S ${STRIPCONF} | grep ^S:${SERVERNAME}`
	OPTIONS=`echo $SLINE | cut -d : -f 5`

	case "${SOPTIONS}" in
		*2*)
			NUMCLIENTS=2048
		;;
		*4*)
			NUMCLIENTS=4096
		;;
		*8*)
			NUMCLIENTS=8192
		;;
	esac

	echo -n "" >${SERVERFILE}

	if [ "${NUMCLIENTS}" != "" ] ; then
		echo "class bigclients {" >>${SERVERFILE}
		echo -e "\tpingfreq 90;" >>${SERVERFILE}
		echo -e "\tmaxclients ${NUMCLIENTS};" >>${SERVERFILE}
		echo -e "\tsendq 256000;" >>${SERVERFILE}
		echo -e "\trecvq 8000;" >>${SERVERFILE}
		echo "};" >>${SERVERFILE}

		echo "" >>${SERVERFILE}

		echo "allow {" >>${SERVERFILE}
		echo -e "\tip *@*;" >>${SERVERFILE}
		echo -e "\thostname *@*;" >>${SERVERFILE}
		echo -e "\tclass bigclients;" >>${SERVERFILE}
		echo -e "\tredirect-server \"irc.geekshed.net\";" >>${SERVERFILE}
		echo "};" >>${SERVERFILE}
	fi

	echo "    - ending ${SERVERFILE}"
}

