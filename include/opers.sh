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
# SUCH DAMAGE.

oper_block () 
{
						echo -e "oper ${OSNAME} {" >>${OPERFILE}
						echo -e "\t/* ${ONICK} - ${OLNAME} - ${OEMAIL} */" >> ${OPERFILE}
						echo -e "\tclass opers;" >> ${OPERFILE}
						echo -e "\tfrom {" >> ${OPERFILE}
						for UHOSTS in `echo ${OHOSTS} | sed s/_/\ /g`
						do
							echo -e "\t\tuserhost \"${UHOSTS}\";" >> ${OPERFILE}
						done
						echo -e "\t};" >> ${OPERFILE}
						case ${OFLAGS} in
							*m*)
								echo -e "\tpassword \"${OPHASH}\" { md5; }; " >> ${OPERFILE}
							;;
							*)
								echo -e "\tpassword \"${OPHASH}\" { sha1; }; " >> ${OPERFILE}
						esac
						echo -e "\tflags {"  >> ${OPERFILE}
						OPACCESS=0
						case ${OFLAGS} in
							*[rg]*)
								echo -e "\t\tnetadmin;" >> ${OPERFILE}
								OPACCESS=3
								OPACCESS=3
							;;
							*a*)
								echo -e "\t\tservices-admin;" >> ${OPERFILE}
								OPACCESS=3
							;;
							*)
								case ${OTYPE} in
									*O*)
										echo -e "\t\tlocal;" >> ${OPERFILE}
										OPACCESS=1
									;;
									*o*)
										echo -e "\t\tglobal;" >> ${OPERFILE}
										OPACCESS=2
									;;
									*C*)
										echo -e "\t\tcoadmin;" >> ${OPERFILE}
										OPACCESS=3
									;;
									*A*)
										echo -e "\t\tadmin;" >> ${OPERFILE}
										OPACCESS=3
									;;
									*a*)
										echo -e "\t\tservices-admin;" >> ${OPERFILE}
										OPACCESS=3
									;;
									*N*)
										echo -e "\t\tnetadmin;" >> ${OPERFILE}
										OPACCESS=3
									;;
								esac
							;;
						esac
						if [ "${OPACCESS}" -ge "1" ]; then
							echo -e "\t\tcan_zline;" >> ${OPERFILE}
							echo -e "\t\tget_umodew;" >> ${OPERFILE}
							echo -e "\t\thelpop;" >> ${OPERFILE}
							echo -e "\t\tget_host;" >> ${OPERFILE}
							echo -e "\t\tcan_rehash;" >> ${OPERFILE}
						fi
						if [ "${OPACCESS}" -ge "2" ]; then
							echo -e "\t\tcan_gkline;" >> ${OPERFILE}
							echo -e "\t\tcan_restart;" >> ${OPERFILE}
							echo -e "\t\tcan_override;" >> ${OPERFILE}
							echo -e "\t\tcan_gzline;" >> ${OPERFILE}
						fi
						if [ "${OPACCESS}" -ge "3" ]; then
							echo -e "\t\tcan_die;" >> ${OPERFILE}
						fi
						echo -e "\t};" >> ${OPERFILE}
						echo -e "\tsnomask cefjknqvFGT;" >> ${OPERFILE}
						if [ "${OWHOIS}" != "" ] ; then
							echo -e "\tswhois \"${OWHOIS}\";" >> ${OPERFILE}
						fi
				    		echo -e "};" >> ${OPERFILE}
						case ${OFLAGS} in
							*b*)
							;;
							*)
								echo -e "admin {" >> ${OPERFILE}
								case ${OFLAGS} in
									*[r]*)
										echo -e "\t\"Root Administrator: ${ONICK}\";" >> ${OPERFILE}
									;;
									*[g]*)
										echo -e "\t\"Global Administrator: ${ONICK}\";" >> ${OPERFILE}
									;;
									*[a]*)
										echo -e "\t\"Services Administrator: ${ONICK}\";" >> ${OPERFILE}
									;;
									*)
										case ${OTYPE} in
											*[oO]*)
												echo -e "\t\"Server Operator: ${ONICK}\";" >> ${OPERFILE}
											;;
											*)
												echo -e "\t\"Server Administrator: ${ONICK}\";" >> ${OPERFILE}
											;;
										esac
									;;
								esac

								echo -e "\t\"- ${OLNAME} <${OEMAIL}>\";" >> ${OPERFILE}
								echo -e "};" >> ${OPERFILE}
							;;
						esac
						
						# Ban Exceptions
						case ${OFLAGS} in
							*[rg]*)
								for UEXCEPTS in `echo ${OEXCEPTS} | sed s/_/\ /g`
								do
									echo -e "except ban {" >> ${OPERFILE}
									echo -e "\tmask ${UEXCEPTS};" >> ${OPERFILE}
									echo -e "};" >> ${OPERFILE}
								done
							;;
							*)
							;;
						esac
}

opers_gen ()
{
	OPERFILE=${CONFPATH}/olines.conf
	echo -e "\t- starting ${OPERFILE}"
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
	echo -e "\t- ending ${OPERFILE}"
}
