#!/bin/bash
#
# scrip to manage host firewal with iptables
# for configuration see

################################ GLOBAL FUNCTIONS

# configuration file
file=/etc/server/firewall.conf
! [ -f ${file} ] && echo -e "\e[1;31m[error] unable to load file: ${file}\e[0;0m" | tee -a /var/log/server/firewall.err && exit 1
. "${file}"

################################ FUNCTIONS

__add_chain() {
	_echoD "${FUNCNAME}():${LINENO} IN \$@=$@"
	[ "$#" -lt 2 ] && _exite "${FUNCNAME}:${LINENO} Wrong parameters numbers (2): $#"

	opts_given="$@"
	opts_short="v:,c:"
	opts_long="values:,comment:"
	opts=$(getopt -o ${opts_short} -l ${opts_long} -n "${0##*/}" -- "$@") || _exite "Wrong or missing options"
	eval set -- "${opts}"

	_echoD "${FUNCNAME}():${LINENO} opts_given=${opts_given} opts=${opts}"
	while [ "$1" != "--" ]
	do
		case "$1" in
			-v|--values)
				shift
				values="$1"
				;;
			-c|--comment)
				shift
				comment="$1"
				;;
			*)
				_exite "Wrong argument: '$1' for arguments '$opts_given'"
				;;
		esac
		shift
	done

	shift
	chain="$1"
	_echoD "${FUNCNAME}():${LINENO} chain='${chain}'"

	_echo  "${comment} ${value}"

	for value in ${values}; do
		chain=${chain//_VAR_/${value}}
		[ "${DRYRUN}" ] && _echo ${chain} || _eval ${chain}
	done
}

__ipt() {
	cmd=${DRYRUN:-iptables}

	_echoD ${cmd} $*
	${cmd} $*
}

__ipt6() {
	cmd=${DRYRUN:-ip6tables}

	_echoD ${cmd} $*
	${cmd} $*
}

__allow() {
	_echo "-------------------------- DEFAULT POLICIES"

	_echo "\nALLOW all INPUT/FORWARD/OUTPUT"
	__ipt -P INPUT ACCEPT
	__ipt -P FORWARD ACCEPT
	__ipt -P OUTPUT ACCEPT

	_echo "\nALLOW all INPUT/FORWARD/OUTPUT - IPV6"
	__ipt6 -P INPUT ACCEPT
	__ipt6 -P FORWARD ACCEPT
	__ipt6 -P OUTPUT ACCEPT
}

__clear() {
	_echo "\n-------------------------- CLEAR"

	_echo "\nCLEAR all rules in Filter/Nat/Mangle table for IPv4"
	__ipt -F
	__ipt -X
	__ipt -Z
	__ipt -t nat -F
	__ipt -t nat -Z
	__ipt -t nat -X
	__ipt -t mangle -Z
	__ipt -t mangle -F
	__ipt -t mangle -X

	_echo "\nCLEAR all rules in Filter/Mangle table for IPv6"
	__ipt6 -F
	__ipt6 -X
	__ipt6 -t mangle -F
	__ipt6 -t mangle -X
}

__clear_nat() {
	_echo "\n-------------------------- CLEAR NAT"

	_echo "\nCLEAR all nat rules for IPv4"
	__ipt -t nat -F
	__ipt -t nat -Z
	__ipt -t nat -X
}

__init() {
	_echo "\n-------------------------- INIT"

	# DROP all connections in filter table
	_echo "\nDROP all INPUT/FORWARD/OUTPUT in Filter table"
	__ipt -P INPUT DROP
	__ipt -P OUTPUT DROP
	__ipt -P FORWARD DROP

	# ALLOW all connections in nat table
	_echo "\nALLOW all PREROUTING/POSTROUTING/OUTPUT in Nat table"
	__ipt -t nat -P PREROUTING ACCEPT
	__ipt -t nat -P POSTROUTING ACCEPT
	__ipt -t nat -P OUTPUT ACCEPT

	# ALLOW all connections in mangle table
	_echo "\nALLOW all PREROUTING/INPUT/OUTPUT/FORWARD/POSTROUTING in Mangle table"
	__ipt -t mangle -P PREROUTING ACCEPT
	__ipt -t mangle -P INPUT ACCEPT
	__ipt -t mangle -P OUTPUT ACCEPT
	__ipt -t mangle -P FORWARD ACCEPT
	__ipt -t mangle -P POSTROUTING ACCEPT

	# CONNECTIONS
	_echo "\nALLOW existing INPUT & new OUTPUT for ${_ETH}"
	__ipt -A INPUT -p all -i ${_ETH} -m state --state ESTABLISHED,RELATED -j ACCEPT
	__ipt -A OUTPUT -p all -o ${_ETH} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	# FORWARD
	_echo "\nALLOW existing incomming FORWARD & new outcomming FORWARD for ${_ETH}"
	__ipt -A FORWARD -p all -i ${_ETH} -m state --state ESTABLISHED,RELATED -j ACCEPT
	__ipt -A FORWARD -p all -o ${_ETH} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	_echo "\nALLOW existing incomming FORWARD & new outcomming FORWARD for ${_ETH_VM}"
	__ipt -A FORWARD -p all -i ${_ETH_VM} -m state --state ESTABLISHED,RELATED -j ACCEPT
	__ipt -A FORWARD -p all -o ${_ETH_VM} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	# LO
	_echo "\nALLOW all INPUT/OUTPUT for lo"
	__ipt -A INPUT -i lo -j ACCEPT
	__ipt -A OUTPUT -o lo -j ACCEPT


	_echo "\n--------- INIT IPV6"

	# DROP all connections in filter table
	_echo "\nDROP all INPUT/FORWARD/OUTPUT in Filter table - IPV6"
	__ipt6 -P INPUT DROP
	__ipt6 -P OUTPUT DROP
	__ipt6 -P FORWARD DROP

	# ALLOW all connections in mangle table
	_echo "\nALLOW all PREROUTING/INPUT/OUTPUT/FORWARD/POSTROUTING in Mangle table - IPV6"
	__ipt6 -t mangle -P PREROUTING ACCEPT
	__ipt6 -t mangle -P INPUT ACCEPT
	__ipt6 -t mangle -P OUTPUT ACCEPT
	__ipt6 -t mangle -P FORWARD ACCEPT
	__ipt6 -t mangle -P POSTROUTING ACCEPT

	# CONNECTIONS
	_echo "\nALLOW existing INPUT & new OUTPUT for ${_ETH} - IPV6"
	__ipt6 -A INPUT -p all -i ${_ETH} -m state --state ESTABLISHED,RELATED -j ACCEPT
	__ipt6 -A OUTPUT -p all -o ${_ETH} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	# FORWARD
	_echo "\nALLOW existing incomming FORWARD & new outcomming FORWARD for ${_ETH} - IPV6"
	__ipt6 -A FORWARD -p all -i ${_ETH} -m state --state ESTABLISHED,RELATED -j ACCEPT
	__ipt6 -A FORWARD -p all -o ${_ETH} -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

	# LO
	_echo "\nALLOW all INPUT/OUTPUT for lo - IPV6"
	__ipt6 -A INPUT -i lo -j ACCEPT
	__ipt6 -A OUTPUT -o lo -j ACCEPT
}

__init_end() {
	_echo "\n-------------------------- INIT END"

	_echo "\nADD chain in filter for INPUT, OUTPUT, FORWARD"
	__ipt -N DROP-INPUT
	__ipt -N DROP-OUTPUT
	__ipt -N DROP-FORWARD

	_echo "\nDROP all INPUT"
	__ipt -A INPUT -j DROP-INPUT
	${_LOG} && __ipt -A DROP-INPUT -m limit --limit 2/min -j LOG --log-prefix "ipt-drop-input " --log-level 4
	__ipt -A DROP-INPUT -j DROP

	_echo "\nDROP all OUTPUT"
	__ipt -A OUTPUT -j DROP-OUTPUT
	${_LOG} && __ipt -A DROP-OUTPUT -m limit --limit 2/min -j LOG --log-prefix "ipt-drop-output " --log-level 4
	__ipt -A DROP-OUTPUT -j DROP

	_echo "\nDROP all FORWARD"
	__ipt -A FORWARD -j DROP-FORWARD
	${_LOG} && __ipt -A DROP-FORWARD -m limit --limit 2/min -j LOG --log-prefix "ipt-drop-forward " --log-level 4
	__ipt -A DROP-FORWARD -j DROP

	${_LOG} && _echo "\n LOG IPV4 activated"

}

__init_nat() {
	_echo "\n-------------------------- INIT NAT"

	# ALLOW all connections in nat table
	_echo "\nALLOW all PREROUTING/POSTROUTING/OUTPUT in Nat table"
	__ipt -t nat -P PREROUTING ACCEPT
	__ipt -t nat -P POSTROUTING ACCEPT
	__ipt -t nat -P OUTPUT ACCEPT
}

__scan() {
	_echo "\n-------------------------- SCAN"

	__ipt -N DROP-SCAN

	# XMAS scans
	_echo "\nDROP INPUT XMAS - FIN,PSH,URG FIN,PSH,URG"
	__ipt -A INPUT -p tcp --tcp-flags FIN,PSH,URG FIN,PSH,URG -j DROP-SCAN
	#__ipt -A INPUT -p tcp --tcp-flags FIN,PSH,URG FIN,PSH,URG -j DROP --log-prefix "ipt-drop-scan XMAS FIN,PSH,URG: "
	#__ipt -A INPUT -p tcp --tcp-flags FIN,PSH,URG FIN,PSH,URG -j DROP

	_echo "\nDROP INPUT XMAS - SYN,RST SYN,RST"
	__ipt -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP-SCAN
	#__ipt -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j LOG --log-prefix "ipt-drop-scan XMAS SYN,RST: "
	#__ipt -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

	_echo "\nDROP INPUT XMAS - ALL ALL"
	__ipt -A INPUT -p tcp --tcp-flags ALL ALL -j DROP-SCAN
	#__ipt -A INPUT -p tcp --tcp-flags ALL ALL -j LOG --log-prefix "ipt-drop-scan XMAS ALL: "
	#__ipt -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

	# NULL scans
	_echo "\nDROP INPUT XMAS - ALL NONE"
	__ipt -A INPUT -p tcp --tcp-flags ALL NONE -j DROP-SCAN
	#__ipt -A INPUT -p tcp --tcp-flags ALL NONE -j LOG --log-prefix "ipt-drop-scan NULL NONE: "
	#__ipt -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

	# Broadcast paquet
	_echo "\nDROP INPUT BROADCAST"
	__ipt -A INPUT -m pkttype --pkt-type broadcast -j DROP-SCAN
	#__ipt -A INPUT -m pkttype --pkt-type broadcast -j LOG --log-prefix "ipt-drop-scan BROADCAST: "
	#__ipt -A INPUT -m pkttype --pkt-type broadcast -j DROP

	${_LOG} && __ipt -A DROP-SCAN -m limit --limit 2/min -j LOG --log-prefix "ipt-drop-scan " --log-level 4
	__ipt -A DROP-SCAN -j DROP
}

__scan2() {
	_echo "\n-------------------------- SCAN V2"

	_echo "\nDROP SCAN2"
	__ipt -N DROP-SCAN2

	_echo "\nDROP INPUT FIN SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j LOG --log-prefix "ipt-drop-scan2 FIN: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP

	_echo "\nDROP INPUT PSH SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j LOG --log-prefix "ipt-drop-scan2 PSH: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP

	_echo "\nDROP INPUT URG SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,URG URG -j LOG --log-prefix "ipt-drop-scan2 URG: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP

	_echo "\nDROP INPUT XMAS SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags ALL ALL -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL ALL -j LOG --log-prefix "ipt-drop-scan2 XMAS scan: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

	_echo "\nDROP INPUT NULL SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags ALL NONE -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL NONE -j LOG --log-prefix "ipt-drop-scan2 NULL scan: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

	_echo "\nDROP INPUT pscan SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j LOG --log-prefix "ipt-drop-scan2 pscan: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

	_echo "\nDROP INPUT pscan 2 SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j LOG --log-prefix "ipt-drop-scan2 pscan 2: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

	_echo "\nDROP INPUT pscan 3 SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j LOG --log-prefix "ipt-drop-scan2 pscan 2: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP

	_echo "\nDROP INPUT SYNFIN-SCAN SCANS"
	__ipt -t filter -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP-SCAN2
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j LOG --log-prefix "ipt-drop-scan2 SYNFIN-SCAN: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP

	# XMAS
	#_echo "\nDROP INPUT NMAP-XMAS-SCAN SCANS"
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL URG,PSH,FIN -j LOG --log-prefix "ipt-drop-scan2 NMAP-XMAS-SCAN: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL URG,PSH,FIN -j DROP

	#_echo "\nDROP INPUT FIN-SCAN SCANS"
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL FIN -j LOG --log-prefix "ipt-drop-scan2 FIN-SCAN: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL FIN -j DROP

	#_echo "\nDROP INPUT NMAP-ID SCANS"
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j LOG --log-prefix "ipt-drop-scan2 NMAP-ID: "
	#__ipt -t filter -A INPUT -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j DROP

	#_echo "\nDROP INPUT SYN-RST SCANS"
	#__ipt -t filter -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j LOG --log-prefix "ipt-drop-scan2 SYN-RST: "

	${_LOG} && __ipt -A DROP-SCAN2 -m limit --limit 2/min -j LOG --log-prefix "ipt-drop-scan2 " --log-level 4
	__ipt -A DROP-SCAN2 -j DROP
}

__ovh() {
	local chain comment

	_echo "\n-------------------------- OVH"

	# OVH
	chain="iptables -A INPUT -i ${_ETH} -p icmp -s _VAR_ -j ACCEPT"
	comment="Allow INPUT ICMP, OVH /SLA/MRTG for IP: "
	__add_chain "${chain}" -v "${_IPSOVHICMP}" -c "$comment"

	chain="iptables -A INPUT -i ${_ETH} -s _VAR_ -j ACCEPT"
	comment="Allow INPUT UDP, *.253 *.252 for IP: "
	__add_chain "${chain}" -v "${_IPTHIS%.*}.252 ${_IPTHIS%.*}.253" -c "$comment"

	chain="iptables -t filter -A OUTPUT -p udp --dport _VAR_ -j ACCEPT"
	comment="Allow OUTPUT UDP, OVH RTM for Port: "
	__add_chain "${chain}" -v "${_PORTOVHRTM}" -c "$comment"
}

__add_rules() {
	local chain comment

	_echo "\n-------------------------- RULES"

	# SSH
	_echo "\nSSH"
	chain="iptables -A INPUT -i ${_ETH} -p tcp -s _VAR_ -d ${_IPTHIS} --sport ${_PORTSSHS} --dport ${_PORTSSH} -j ACCEPT"
	comment="Allow INPUT port: ${_PORTSSHS} -> ${_PORTSSH} SSH, for IP: "
	__add_chain "${chain}" -v "${_IPSSSH}" -c "$comment"

	# ICMP
	_echo "\nICMP"
	chain="iptables -A INPUT -i ${_ETH} -p icmp -s _VAR_ -j ACCEPT"
	comment="Allow INPUT ICMP for IP:"
	__add_chain "${chain}" -v "${_IPSICMP}" -c "$comment"

	# RSYSLOG
	_echo "\nRSYSLOG"
	chain="iptables -A INPUT -i ${_ETH} -p udp -s _VAR_ --dport ${_PORTRSYSLOG} -j ACCEPT"
	comment="Allow INPUT ICMP for IP on ${_ETH_VM}:"
	__add_chain "${chain}" -v "${_IPSRSYSLOG}" -c "$comment"

	# DNS
	_echo "\nDNS"
	chain="iptables -A INPUT -i ${_ETH} -p tcp -s _VAR_ --dport $_PORTDNS -j ACCEPT"
	comment="Allow INPUT port: $_PORTDNS, TCP DNS for IP:"
	__add_chain "${chain}" -v "${_IPSDNS}" -c "$comment"

	chain="iptables -A INPUT -i ${_ETH} -p udp -s _VAR_ --dport $_PORTDNS -j ACCEPT"
	comment="Allow INPUT port: $_PORTDNS, UDP DNS for IP:"
	__add_chain "${chain}" -v "${_IPSDNS}" -c "$comment"

	# NTP (time) server
	#_echo "\nNTP"
	#chain="iptables -A INPUT -i ${_ETH} -p udp --sport $_PORTNTP --dport $_PORTNTP -j ACCEPT"
	#comment="Allow INPUT port: $_PORTNTP, UDP NTP for IP:"
	#__add_chain "${chain}" -v "$_IPSNTP" -c "$comment"

	# HTTP
	if [ "$_LIMITHTTP" ]; then
		_echo "\nHTTP LIMIT"
		chain="iptables -A INPUT -i ${_ETH} -p tcp --syn --dport _VAR_ -m limit --limit $_LIMITHTTP --limit-burst $_LIMITBURSTHTTP -j ACCEPT"
		comment="Allow INPUT all IPs Mails with LIMIT $_LIMITHTTP & Burst $_LIMITBURSTHTTP for Port: "
	else
		_echo "\nHTTP"
		chain="iptables -A INPUT -i ${_ETH} -p tcp --dport _VAR_ -j ACCEPT"
		comment="Allow INPUT all IPs HTTP for Port: "
	fi
	__add_chain "${chain}" -v "${_PORTSHTTP}" -c "$comment"

	if [ "$_CONMAXHTTP" ]; then
		_echo "\nHTTP CONMAX"
		#chain="iptables -A INPUT -i ${_ETH} -p tcp --dport _VAR_ -j ACCEPT"
		chain="iptables -A INPUT -i ${_ETH} -p tcp --syn --dport _VAR_ -m connlimit --connlimit-upto $_CONMAXHTTP --connlimit-mask 32 -j LOG --log-prefix "ipt-fw-limit-$port $_CONMAXHTTP HTTP _VAR_ : ""
		comment="Log LIMIT INPUT all IPs HTTP with max // connLimit of $_CONMAXHTTP for Port: "
		__add_chain "${chain}" -v "${_PORTSHTTP}" -c "$comment"

		chain="iptables -A INPUT -i ${_ETH} -p tcp --syn --dport _VAR_ -m connlimit --connlimit-upto $_CONMAXHTTP --connlimit-mask 32 -j DROP"
		comment="Log DROPPED INPUT all IPs HTTP with max // connLimit of $_CONMAXHTTP for Port: "
		__add_chain "${chain}" -v "${_PORTSHTTP}" -c "$comment"
	fi

	# MAIL
	if [ "$_LIMITMAIL" ]; then
		_echo "\MAIL LIMIT"
		chain="iptables -A INPUT -i ${_ETH} -p tcp --syn --dport _VAR_ -m limit --limit $_LIMITMAIL --limit-burst $_LIMITBURSTMAIL -j ACCEPT"
		comment="Allow INPUT all IPs Mails with LIMIT $_LIMITMAIL & Burst $_LIMITBURSTMAIL for Port: "
	else
		_echo "\MAIL"
		chain="iptables -A INPUT -i ${_ETH} -p tcp --dport _VAR_ -j ACCEPT"
		comment="Allow INPUT all IPs Mails for Port: "
	fi
	__add_chain "${chain}" -v "${_PORTSMAIL}" -c "$comment"

	# HAPROXY
	_echo "\nHAPROXY"
	for port in $_PORTHAPROXY; do
		chain="iptables -A INPUT -i ${_ETH} -p tcp -s _VAR_ -d ${_IPTHIS} --dport _VAR_ -j ACCEPT"
		comment="Allow INPUT HAPROXY for IP:${_IPSHAPROXY} port:$port"
		__add_chain "${chain}" -v "${_IPSHAPROXY}" -c "$comment"
	done

	# MariaDB
	#chain="iptables -A INPUT -i ${_ETH} -p tcp -s _VAR_ --sport $_PORTMARIADBS -d ${_IPTHIS} --dport $_PORTMARIADB -m state --state NEW,ESTABLISHED -j ACCEPT"
	chain="iptables -A INPUT -i ${_ETH} -p tcp -s _VAR_ --sport $_PORTMARIADB -d ${_IPTHIS} --dport $_PORTMARIADB -m state --state NEW,ESTABLISHED -j ACCEPT"
	comment="Allow INPUT port: $_PORTMARIADB -> $_PORTMARIADB, MariaDB for IP:"
	__add_chain "${chain}" -v "${_IPSMARIADB}" -c "$comment"

	#chain="iptables -A OUTPUT -p tcp -s ${_IPTHIS} --sport $_PORTMARIADB -d _VAR_ --dport $_PORTMARIADBS -m state --state ESTABLISHED -j ACCEPT"
	#comment="Allow OUTPUT port: $_PORTMARIADB -> $_PORTMARIADBS, MariaDB for IP:"
	#__add_chain "${chain}" -v "${_IPSMARIADB}" -c "$comment"

	# PostgreSQL
	#chain="iptables -A INPUT -i ${_ETH} -p tcp -s _VAR_ --sport ${_PORTPGSQLS} -d ${_IPTHIS} --dport ${_PORTPGSQL} -m state --state NEW,ESTABLISHED -j ACCEPT"
	chain="iptables -A INPUT -i ${_ETH} -p tcp -s _VAR_ --sport ${_PORTPGSQL} -d ${_IPTHIS} --dport ${_PORTPGSQL} -m state --state NEW,ESTABLISHED -j ACCEPT"
	comment="Allow INPUT port: ${_PORTPGSQL} -> ${_PORTPGSQL}, PostgreSQL for IP:"
	__add_chain "${chain}" -v "${_IPSPGSQL}" -c "$comment"

	#chain="iptables -A OUTPUT -p tcp -s ${_IPTHIS} --sport ${_PORTPGSQL} -d _VAR_ --dport ${_PORTPGSQLS} -m state --state ESTABLISHED -j ACCEPT"
	#comment="Allow OUTPUT port: ${_PORTPGSQL} -> ${_PORTPGSQLS}, PostgreSQL for IP:"
	#__add_chain "${chain}" -v "${_IPSPGSQL}" -c "$comment"

}

__vm_ssh() {
	_echo "\n-------------------------- VM SSH"

	if [ "$S_HOST_TYPE" == vz ] && [ "$_VM_SSH" == "y" ] && ctids=$(vzlist -aHo ctid); then
		for ctid in $ctids
		do
			ctip=${_VM_IP_BASE}.${ctid}
			port_from=${S_HOST_PORT_PRE_SSH}${ctid}
			port_to=${_PORTSSH}
			_echoD "VM - PREROUTING ${_ETH} / SSH $ctip: ${port_from} > ${port_to}"
			__ipt -t nat -A PREROUTING -j DNAT -i ${_ETH} -p tcp -d ${_IPTHIS} --dport ${port_from} --to-destination ${ctip}:${port_to}
			_echo "Allow PREROUTING ${_ETH} / SSH port ${port_from} to ct ${ctip}:${port_to}"
		done
	fi
}

__vm_nat() {
	_echo "\n-------------------------- VM NAT"

	for ID in ${!_PORTSIDVM[@]}
	do
		ctid=${ID:0:3}
		ctip=${_VM_IP_BASE}.${ctid}
		for PORTS in ${_PORTSIDVM[$ID]}
		do
			port_from=${PORTS%-*}
			port_to=${PORTS#*-}
			_echoD "VM - PREROUTING ${_ETH} / $ctip: ${port_from} > ${port_to}"
			#__ipt -t nat -A PREROUTING -i "${_ETH}" -d "${_IPTHIS}" -p tcp --dport "${port_from}" -j DNAT --to-destination "${ctip}:${port_to}"
			#__ipt -t nat -A PREROUTING -i "${_ETH}" -p tcp --dport "${port_from}" -j DNAT --to-destination "${ctip}:${port_to}"
			__ipt -t nat -A PREROUTING -d "${_IPTHIS}" -p tcp --dport ${port_from} -j DNAT --to-destination ${ctip}:${port_to}
			__ipt -t nat -A OUTPUT -p tcp -o lo --dport ${port_from} -j DNAT --to-destination ${ctip}:${port_to}
			_echo "Allow PREROUTING ${_ETH} / port ${port_from} to ct ${ctip}:${port_to}"
		done
	done
}

__vm_nat_admin() {
	_echo "\n-------------------------- VM NAT ADMIN"

	for ip_admin in ${S_IPS_ADMIN[@]}
	do
		for ID in ${!_PORTSIDVM_ADMIN[@]}
		do
			ctid=${ID:0:3}
			ctip=${_VM_IP_BASE}.${ctid}
			for PORTS in ${_PORTSIDVM_ADMIN[$ID]}
			do
				port_from=${PORTS%-*}
				port_to=${PORTS#*-}
				_echoD "VM ADMIN - PREROUTING ${_ETH} / $ctip: ${port_from} > ${port_to}"
				__ipt -t nat -A PREROUTING -i ${_ETH} -s ip_admin -d ${_IPTHIS} -p tcp --dport ${port_from} -j DNAT --to-destination ${ctip}:${port_to}
				_echo "Allow PREROUTING ${_ETH} / port ${port_from} to ct ${ctip}:${port_to}"
			done
		done
	done
}

__vm_init() {
	_echo "\n-------------------------- VM INIT"

	# _ETH_VM
	__ipt -A INPUT -i ${_ETH_VM} -j ACCEPT
	__ipt -A OUTPUT -o ${_ETH_VM} -j ACCEPT
	_echo "Allow INPUT/OUTPUT ${_ETH_VM} connections INPUT/OUTPUT"

	# Output access
	#__ipt -t nat -A POSTROUTING -s ${_VM_IP_BASE}.1/24 -o ${_ETH} -j SNAT --to ${_IPTHIS}
	__ipt -t nat -A POSTROUTING -o ${_ETH} -j MASQUERADE
	_echo "Allow OUTPUT acces to all cts"

	__ipt -A FORWARD -i ${_ETH} -p tcp -d ${_VM_IP_BASE}.1/24 -j ACCEPT
	_echo "Allow FORWARD to ${_VM_IP_BASE}.1/24 port all"
	#__ipt -A FORWARD -i ${_ETH} -p tcp --dport 80 -d $_VM_IP_BASE.$_ctid_80_vm/32 -j ACCEPT
	#_echo "Allow FORWARD to ${_VM_IP_BASE}.$_ctid_80_vm/32 port 80"
	#__ipt -A FORWARD -i ${_ETH} -p tcp --dport 8100:8254 -d ${_VM_IP_BASE}.1/24 -j ACCEPT
	#_echo "Allow FORWARD to ${_VM_IP_BASE}.1/24 port 8100:8254"


	# 80
	#__ipt -t nat -A PREROUTING -j DNAT -i ${_ETH} -p tcp -d ${_IPTHIS} --dport 80 --to-destination $_VM_IP_BASE.$_ctid_80_vm:80
	#_echo "Allow PREROUTING port 80 to ct $_VM_IP_BASE.$_ctid_80_vm:80"
	# __ipt -t nat -A POSTROUTING -s $ctIp -o ${_ETH} -j SNAT --to $hIp # if web access is not already given
	# __ipt -t nat -A POSTROUTING -o ${_ETH} -p tcp --dport $hPort -d $ctIp -j MASQUERADE # if web access is not already given
}

__vm_init_nat() {
	_echo "\n-------------------------- VM INIT NAT"

	# Output access
	#__ipt -t nat -A POSTROUTING -s ${_VM_IP_BASE}.1/24 -o ${_ETH} -j SNAT --to ${_IPTHIS}
	__ipt -t nat -A POSTROUTING -o ${_ETH} -j MASQUERADE
	_echo "Allow OUTPUT acces to all cts"
}

__vm_rules() {
	_echo "\n-------------------------- VM RULES"

	__vm_nat
	__vm_nat_admin
	#__vm_ssh
}


################################ MAIN

_echo "\n================================================= Firewall"

case $1 in
start)
	_echo "\n========================== firewall STARTING"

	__init
	__ovh
	${is_fail2ban} && ${_FAIL2BAN} && _service fail2ban start && _echo "\n------------- fail2ban STARTED"
	__add_rules
	$is_vz && __vm_init && __vm_rules
	__scan
	__init_end

	_echo "\n========================== firewall STARTED"
	;;
stop)
	_echo "\n========================== firewall STOPING"

	${is_fail2ban} && ${_FAIL2BAN} && _service fail2ban stop && _echo "\n------------- fail2ban STOPPED"
	__allow
	__clear

	_echo "\n========================== firewall STOPED"
	;;
restart)
	_echo "\n========================== firewall RESTARTING"

	${is_fail2ban} && ${_FAIL2BAN} && _service fail2ban stop && _echo "\n------------- fail2ban STOPPED"
	__allow
	__clear
	__init
	__ovh
	${is_fail2ban} && ${_FAIL2BAN} && _service fail2ban start && _echo "\n------------- fail2ban STARTED"
	__add_rules
	$is_vz && __vm_init && __vm_rules
	__scan
	__init_end

	_echo "\n========================== firewall RESTARTED"
	;;
*)
	_echo "Usage: $SCRIPTNAME {start|stop|restart}"
	_exit 3
	;;
esac

_exit 0
