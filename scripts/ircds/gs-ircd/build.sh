#!/usr/bin/env bash
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
# SUCH DAMAGE.



build_main() {
	beachball >&2 &
	BEACHBALLPID=$!
	bunzip2 | tar -xvpf - -C "${SERVERPWD}"
	OS="$(uname -s)"
	RELEASE="$(uname -r)"
	echo "OS=${OS}"
	echo "RELEASE=${RELEASE}"
	case "${OS}" in
		[fF][rR][eE][eE][bB][sS][dD])
			MAJOR="$(echo ${RELEASE} | cut -d . -f 1)"
			echo "MAJOR=${MAJOR}"
			if [ "${MAJOR}" -ge 10 ] ; then
				CONFPARAMS="--enable-hub --enable-prefixaq --with-showlistmodes --with-listen=5 --with-dpath=${SERVERPWD}/${NETSHORTNAME}-ircd  --with-spath=${SERVERPWD}/${NETSHORTNAME}-ircd/src/ircd --with-nick-history=2000 --with-sendq=3000000 --with-bufferpool=18 --with-hostname=127.0.0.1 --with-permissions=0600 --enable-dynamic-linking"

			else
				CONFPARAMS="--enable-hub --enable-prefixaq --with-showlistmodes --with-listen=5 --with-dpath=${SERVERPWD}/${NETSHORTNAME}-ircd  --with-spath=${SERVERPWD}/${NETSHORTNAME}-ircd/src/ircd --with-nick-history=2000 --with-sendq=3000000 --with-bufferpool=18 --with-hostname=127.0.0.1 --with-permissions=0600 --enable-dynamic-linking"
			fi
		;;
		*)
			CONFPARAMS="--enable-hub --enable-prefixaq --with-showlistmodes --with-listen=5 --with-dpath=${SERVERPWD}/${NETSHORTNAME}-ircd  --with-spath=${SERVERPWD}/${NETSHORTNAME}-ircd/src/ircd --with-nick-history=2000 --with-sendq=3000000 --with-bufferpool=18 --with-hostname=127.0.0.1 --with-permissions=0600 --enable-dynamic-linking"
		;;
	esac
	case "${FLAGS}" in *z*) CONFPARAMS="${CONFPARAMS} --enable-ziplinks" ;; esac
	case "${FLAGS}" in *v*) CONFPARAMS="${CONFPARAMS} --enable-inet6" ;; esac
	case "${FLAGS}" in *s*) CONFPARAMS="${CONFPARAMS} --enable-ssl" ;; esac
	case "${FLAGS}" in *2*) CONFPARAMS="${CONFPARAMS} --with-fd-setsize=2048" ;; esac
	case "${FLAGS}" in *4*) CONFPARAMS="${CONFPARAMS} --with-fd-setsize=4096" ;; esac
	case "${FLAGS}" in *8*) CONFPARAMS="${CONFPARAMS} --with-fd-setsize=8192" ;; esac

	cd ${NETSHORTNAME}-ircd
	./configure ${CONFPARAMS} 
	case "${OS}" in
		[fF][rR][eE][eE][bB][sS][dD])
			MAJOR="$(echo ${RELEASE} | cut -d . -f 1)"
			echo "MAJOR=${MAJOR}"
			if [ "${MAJOR}" -ge 10 ] ; then
				sed -i .bak "s@-lcrypt@-lcrypt -lintl@g" "${SERVERPWD}/${NETSHORTNAME}-ircd/Makefile"
			fi
		;;
	esac
	case "${FLAGS}" in *d*) echo "#define DEBUGMODE" >>"include/config.h";; esac
	case "${FLAGS}" in *d*) echo "#define DEBUG" >>"include/config.h";; esac

	cd .
	make clean
	make

	sed s_%%DATADIR%%_${NETSHORTNAME}-data_g unrealircd.conf.base | sed s_%%IRCDDIR%%_${NETSHORTNAME}-ircd_g > unrealircd.conf

	if [ -f makemodules ]; then chmod +x makemodules; 
		./makemodules;
	fi
	kill -9 "${BEACHBALLPID}" >/dev/null 2>/dev/null
}
