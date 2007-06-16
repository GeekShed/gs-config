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
conf_init ()
{
        # set var's to use
        SCRIPTROOT=`pwd`
        CONFIG=${SCRIPTROOT}/conf/network.conf ; export CONFIG
        SHELL=/bin/sh ; export SHELL
        OUTPUTPATH=/tmp/cf-gen ; export OUTPUTPATH
        rm -rf ${OUTPUTPATH}
        mkdir -p ${OUTPUTPATH}
        chmod 750 ${OUTPUTPATH}
        NAME=${CONFIG} ; export NAME
        # stripping out comments and whitespace:
        grep -v ^# ${NAME} | grep -v ^$ | cut -f 1 -d \# > ${OUTPUTPATH}/network.conf
        STRIPCONF=${OUTPUTPATH}/network.conf ; export STRIPCONF
        mkdir -p ${OUTPUTPATH}/conf
        NETWORK=`grep ^N ${STRIPCONF} | cut -d : -f 2` ; export NETWORK
	DNSSUFFIX=`grep ^N ${STRIPCONF} | cut -d : -f 3`
}
ossh() {
        local SERVER=`grep ^S ${STRIPCONF} | grep "${1}"`
        shift
        local SSHIP=`echo "${SERVER}" | cut -d : -f 4`
        if [ "${SSHIP}" = "" ] ; then
                local SSHIP=`echo "${SERVER}" | cut -d : -f 3 | sed s/-/\ /g | awk ' { print $1; }'`
        fi
        local USERNAME=`echo "${SERVER}" | cut -d : -f 9`
        local PORT=`echo "${SERVER}" | cut -d : -f 10 `
        if [ "${PORT}" = "" ] ; then
                local PORT=22
        fi
        ssh -p ${PORT} ${USERNAME}@${SSHIP} sh -c \"$*\"
}

