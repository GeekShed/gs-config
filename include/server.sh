#!/usr/bin/env bash
# Portions Copyright (c) 2005-2007  WyldRyde IRC Network
# Copyright (c) 2009 GeekShed Ltd.
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
server_gen ()
{
	SERVERFILE=${CONFPATH}/server.conf
	echo "    - starting ${SERVERFILE}"
	SLINE=`grep ^S ${STRIPCONF} | grep ^S:${SERVERNAME}`
	NAME=${SERVERNAME}.${DNSSUFFIX}
	NUMERIC=`echo ${SLINE} | cut -d : -f 6`
	PASS=`echo ${SLINE} | cut -d : -f 7`
	INFO=`echo ${SLINE} | cut -d : -f 11 | sed s/\_/\ /g`
	echo "me {" >>${SERVERFILE}
	echo "    name \"${NAME}\";" >>${SERVERFILE}
	echo "    info \"${INFO}\";" >>${SERVERFILE}
	echo "    numeric ${NUMERIC};" >>${SERVERFILE}
	echo "};" >>${SERVERFILE}
	echo "drpass {" >>${SERVERFILE}
	echo "    restart \"${PASS}\" { sha1; };" >>${SERVERFILE}
	echo "    die \"${PASS}\" { sha1; };" >>${SERVERFILE}
	echo "};" >>${SERVERFILE}
	echo "admin {" >>${SERVERFILE}
	echo "    \"${NETWORK} IRC Network\";" >>${SERVERFILE}
	echo "};" >>${SERVERFILE}
	echo "    - ending ${SERVERFILE}"
}

