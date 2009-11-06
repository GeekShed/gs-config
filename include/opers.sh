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
# SUCH DAMAGE.

oper_block () 
{
						echo "oper ${OSNAME} {" >>${OPERFILE}
						echo "    /* ${ONICK} - ${OLNAME} - ${OEMAIL} */" >> ${OPERFILE}
						echo "    class opers;" >> ${OPERFILE}
						echo "    from {" >> ${OPERFILE}
						for UHOSTS in `echo ${OHOSTS} | sed s/_/\ /g`
						do
							echo "        userhost \"${UHOSTS}\";" >> ${OPERFILE}
						done
						echo "    };" >> ${OPERFILE}
						OSNAMELOWER=`echo $OSNAME | tr "[:upper:]" "[:lower:]"`
						case ${OFLAGS} in
							*s*)
								echo "    password \"../${NETSHORTNAME}-data/${NETSHORTNAME}-ircd/client-certs/${OSNAMELOWER}.pem\" { sslclientcert; }; " >> ${OPERFILE}
							;;
							*)
								case ${#OPHASH} in
									13)
										echo "    password \"${OPHASH}\" { crypt; }; " >> ${OPERFILE}
									;;
									34)
										echo "    password \"${OPHASH}\" { md5; }; " >> ${OPERFILE}
									;;
									38)
										echo "    password \"${OPHASH}\" { sha1; }; " >> ${OPERFILE}
									;;
								esac
						esac
						echo "    flags {"  >> ${OPERFILE}
						OPACCESS=0
						case ${OFLAGS} in
							*r*)
								echo "        netadmin;" >> ${OPERFILE}
								OPACCESS=3
							;;
							*[ag]*)
								echo "        services-admin;" >> ${OPERFILE}
								OPACCESS=3
							;;
							*)
								case ${OTYPE} in
									*O*)
										echo "        local;" >> ${OPERFILE}
										OPACCESS=1
									;;
									*o*)
										echo "        global;" >> ${OPERFILE}
										OPACCESS=2
									;;
									*C*)
										echo "        coadmin;" >> ${OPERFILE}
										OPACCESS=3
									;;
									*A*)
										echo "        admin;" >> ${OPERFILE}
										OPACCESS=3
									;;
									*a*)
										echo "        services-admin;" >> ${OPERFILE}
										OPACCESS=3
									;;
									*N*)
										echo "        netadmin;" >> ${OPERFILE}
										OPACCESS=3
									;;
								esac
							;;
						esac
						if [ "${OPACCESS}" -ge "1" ]; then
							echo "        can_zline;" >> ${OPERFILE}
							echo "        get_umodew;" >> ${OPERFILE}
							echo "        helpop;" >> ${OPERFILE}
							echo "        get_host;" >> ${OPERFILE}
							echo "        can_rehash;" >> ${OPERFILE}
						fi
						if [ "${OPACCESS}" -ge "2" ]; then
							echo "        can_gkline;" >> ${OPERFILE}
							echo "        can_restart;" >> ${OPERFILE}
							echo "        can_override;" >> ${OPERFILE}
							echo "        can_gzline;" >> ${OPERFILE}
						fi
						if [ "${OPACCESS}" -ge "3" ]; then
							echo "        can_die;" >> ${OPERFILE}
						fi
						echo "    };" >> ${OPERFILE}
						echo "    snomask cefjknqvFGT;" >> ${OPERFILE}
						if [ "${OWHOIS}" != "" ] ; then
							echo "    swhois \"${OWHOIS}\";" >> ${OPERFILE}
						fi
				    		echo "};" >> ${OPERFILE}
						case ${OFLAGS} in
							*b*)
							;;
							*)
								echo "admin {" >> ${OPERFILE}
								case ${OFLAGS} in
									*[r]*)
										echo "    \"Root Administrator: ${ONICK}\";" >> ${OPERFILE}
									;;
									*[g]*)
										echo "    \"Global Administrator: ${ONICK}\";" >> ${OPERFILE}
									;;
									*[a]*)
										echo "    \"Services Administrator: ${ONICK}\";" >> ${OPERFILE}
									;;
									*)
										case ${OTYPE} in
											*[oO]*)
												echo "    \"Server Operator: ${ONICK}\";" >> ${OPERFILE}
											;;
											*)
												echo "    \"Server Administrator: ${ONICK}\";" >> ${OPERFILE}
											;;
										esac
									;;
								esac

								echo "    \"- ${OLNAME} <${OEMAIL}>\";" >> ${OPERFILE}
								echo "};" >> ${OPERFILE}
							;;
						esac
						
						# Ban Exceptions
						case ${OFLAGS} in
							*[rg]*)
								for UEXCEPTS in `echo ${OEXCEPTS} | sed s/_/\ /g`
								do
									echo "except tkl {" >> ${OPERFILE}
									echo "    mask ${UEXCEPTS};" >> ${OPERFILE}
									echo "    type { " >> ${OPERFILE}
									echo "        gline;" >> ${OPERFILE}
									echo "        gzline;" >> ${OPERFILE}
									echo "        shun;" >> ${OPERFILE}
									echo "        qline;" >> ${OPERFILE}
									echo "    };" >> ${OPERFILE}
									echo "};" >> ${OPERFILE}
								done
							;;
							*)
							;;
						esac
}

opers_gen ()
{
	OPERFILE=${CONFPATH}/olines.conf
	echo "    - starting ${OPERFILE}"
	for OLINES in `grep ^U ${STRIPCONF}`
	do
		OSNAME=`echo ${OLINES} | cut -d : -f 2`
		OLNAME=`echo ${OLINES} | cut -d : -f 3| sed s/\_/\ /g`
		OPHASH=`echo ${OLINES} | cut -d : -f 4`
		OFLAGS=`echo ${OLINES} | cut -d : -f 5`
		OHOSTS=`echo ${OLINES} | cut -d : -f 7`
		OEXCEPTS=`echo ${OLINES} | cut -d : -f 11`
		OEMAIL=`echo ${OLINES} | cut -d : -f 8`
		ONICK=`echo ${OLINES} | cut -d : -f 9`
		OWHOIS=`echo ${OLINES} | cut -d : -f 10| sed s/\_/\ /g`
		OSERVERS=`echo ${OLINES} | cut -d : -f 6 | sed s/-/\ /g`
		MASTERSERVER=`grep ^N ${STRIPCONF} | cut -d : -f 4`
		case ${OFLAGS} in
			*g*)
				oper_block
			;;
			*r*)
				oper_block
			;;
			*)
				if [ "${SERVERNAME}" = "${MASTERSERVER}" ] ; then
					OTYPE=o
					oper_block 
				else
					for USERVERS in ${OSERVERS}
					do
						OTYPE=`echo ${USERVERS} | cut -f 1 -d @`
						OSERVER=`echo ${USERVERS} | cut -f 2 -d @`
						if [ "${OSERVER}" = "${SERVERNAME}" ] ; then
							oper_block
						fi
					done
				fi
			;;
		esac 
	done
	echo "    - ending ${OPERFILE}"
}
