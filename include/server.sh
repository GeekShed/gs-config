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
server_gen ()
{
	SERVERFILE=${CONFPATH}/server.conf
	echo -e "\t- starting ${SERVERFILE}"
	SLINE=`grep ^S ${STRIPCONF} | grep ${SERVERNAME}`
	NAME=${SERVERNAME}.${NETWORK}
	NUMERIC=`echo ${SLINE} | cut -d : -f 6`
	PASS=`echo ${SLINE} | cut -d : -f 7`
	INFO=`cat ${SCRIPTROOT}/conf/wyldryde/${SERVERNAME}/info`
	echo -e "me {" >>${SERVERFILE}
	echo -e "\tname \"${NAME}\";" >>${SERVERFILE}
	echo -e "\tinfo \"${INFO}\";" >>${SERVERFILE}
	echo -e "\tnumeric ${NUMERIC};" >>${SERVERFILE}
	echo -e "};" >>${SERVERFILE}
	echo -e "drpass {" >>${SERVERFILE}
	echo -e "\trestart \"${PASS}\" { sha1; };" >>${SERVERFILE}
	echo -e "\tdie \"${PASS}\" { sha1; };" >>${SERVERFILE}
	echo -e "};" >>${SERVERFILE}
	echo -e "admin {" >>${SERVERFILE}
	echo -e "\t\"WyldRyde IRC Network\";" >>${SERVERFILE}
	echo -e "};" >>${SERVERFILE}
	echo -e "\t- ending ${SERVERFILE}"
}

