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
        for REMOTESERVER in `grep ^S ${STRIPCONF} | grep -v ${SERVERNAME}`
        do
		LINKFILE=${CONFPATH}/links.conf
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
                if [ "${REGION}" != "0" ] ; then
                        if [ "${REGION}" != "" ] ; then
                                for HLINES in `grep ^H ${STRIPCONF}`
                                do
                                        if [ "`echo ${HLINES} | cut -f 2 -d :`" == ${REGION} ] ; then
                                                if [ "`echo ${HLINES} | cut -f 3 -d :`" == ${LINKNAME} ] ; then
                                                        echo "\t\tautoconnect;" >> ${LINKFILE}
                                                fi
                                        fi
                                done
                        fi
                fi
                echo "\t};" >> ${LINKFILE}
                echo "};\n" >> ${LINKFILE}
        done  

}
