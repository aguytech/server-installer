#!/bin/sh
#
# 1					2			3							4				5			6		7							8						9
# action		state	name					ip				port	@	master-name	master-ip		master-port
# +sdown	slave	redis-1:6379	redis-1	6379	@	mymaster		10.0.0.48	6379
#
# settings
# file settings for sentinel
file_sentinel=/etc/sentinel.conf
# options: syslog or file
log=syslog
# syslog programe name
syslog_name=notify/redis
# file to log
file_log=S_PATH_LOG/redis/notify.log
# time in seconds to wait before get role
time_before=0
# time in seconds between repeat
time_repeat=2
# time in seconds between switch to replicate data
time_switch=8
# time in seconds to wait before last check
time_check=4
# number of repeat to switch master to slave
repeat=10
# debugging log (everything not empty)
debug=

########################  functions

_log() { echo ${log_date}${id} $* | ${logcmd}; }
#_log_d() { echo ${log_date} ${id} debug $* >> ${file_log}; }
if [ -n "$debug" ]; then
	_log_d() { echo ${log_date}${id} debug $*  | ${logcmd}; }
else
	_log_d() { :; }
fi
_exit() { test "$*" && _log $*; exit 0; }
_exit_d() { test "$*" && _log_d $*; exit 0; }
_exit_e() { test "$*" && _log $*; exit 2; }
_get_ping() {
	local cmd result

	cmd="redis-cli -h ${s1_ip} -p ${s1_port} PING"
	_log_d "${cmd}"
	result=$(eval ${cmd})
	if [ "$result" = "PONG" ]; then
		_log_d "[ping] ${s1_ip} ${s1_port} = $result"
		return 0
	else
		_log "[ping] ${s1_ip} ${s1_port} = $result"
		return 1
	fi
}
_get_role() {
	local role

	_get_ping || return 1
	cmd="redis-cli -h $1 -p $2 info replication|grep role|xargs"
	_log_d "${cmd}"
	role=$(eval ${cmd})
	role=${role#role:}
	_log "[role] $1:$2 = ${role}"
	echo ${role}
}
_switch() {
	redis-cli -h ${mymaster_ip} -p ${s1_port}
}
_get_ip() {
	if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
		echo $1
	else
		echo $(nslookup -type=a $1|grep '^Address: '|cut -d' ' -f2)
	fi
}
_send() {
	eval redis-cli $*
	_log "[send] $*"
}
_sleep() {
	_log "[sleep] $1"
	sleep $1
}

########################  variables

if [ "$log" = syslog ]; then
	logcmd="logger -p local7.info -t notify/redis"
	log_date=
else
 	logcmd="tee -a ${file_log}"
	log_date="$(date "+%b %e %T") "
fi
#ddate=$(date +%Y%m%d-%H:%m:%S)
id=$(cat /proc/sys/kernel/random/uuid); id=${id%%-*}
mymaster=$(grep '^#mymaster ' "${file_sentinel}"| cut -d' ' -f2)
mymaster_ip=$(_get_ip "${mymaster}")
_lod_d "mymaster=${mymaster} mymaster_ip=${mymaster_ip}"

########################  main

_log "[notify] $*"
set -- $*
# set variables
action="$1"
type="$2"
# s1 is the slave that restarted (in this state the originaly mymaster)
s1_ip=$(_get_ip "$4")
s1_port="$5"
# s2 is the master (in this state the replicaof mymaster, for a cluster of two, the slave of mymaster)
s2_ip=$(_get_ip "$8")
s2_port="$9"
_log_d "action=${action} type=${type}"
_log_d "s1_ip=${s1_ip} s1_port=${s1_port} s2_ip=${s2_ip} s2_port=${s2_port}"

#### filters
[ "$action" != "-sdown" -o "${type}" != "slave" ] && _exit_d "[skip] action=${action} type=${type}"
[ -z "${s1_ip}" -o -z "${s1_port}" ] && _exit_e "[skip] s1_ip=${s1_ip} s1_port=${s1_port}"
[ "${s1_ip}" != "${mymaster_ip}" ] && _exit "[skip] s1_ip=${s1_ip} mymaster_ip=${mymaster_ip}"
#[[ "$4" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]] && _exit "not ip: $4" # not IP
#nslookup -type=a redis-2|grep '^Address: '|cut -d' ' -f2
_log_d "s1_ip=${s1_ip} s1_port=${s1_port} s2_ip=${s2_ip} s2_port=${s2_port}"

if [ "$action" = "-sdown" -a "${type}" = "slave" ]; then

	_log "[start] $*"
	# switch s1 to slave
	_sleep ${time_before}
	i=0
	while [ $i -lt $repeat ]; do
		let "i = i + 1"
		role_s1=$(_get_role ${s1_ip} ${s1_port})
		role_s2=$(_get_role ${s2_ip} ${s2_port})
		if [ "${role_s1}" = master ]; then
			_send -h ${s2_ip} -p ${s_port} REPLICAOF no one
			_send -h ${s1_ip} -p ${s1_port} REPLICAOF ${s2_ip} ${s2_port}
			role_s1=$(_get_role ${s1_ip} ${s1_port})
			role_s2=$(_get_role ${s2_ip} ${s2_port})
			i=$repeat
		fi
		_sleep ${time_repeat}
	done

	# switch s1 to master with a failobver on s2
	_sleep ${time_switch}
	#_send -h ${s2_ip} -p 2${s2_port} sentinel failover mymaster

	# check both server are the same state
	for i in $(seq 1 ${repeat}); do
		role_s1=$(_get_role ${s1_ip} ${s1_port})
		role_s2=$(_get_role ${s2_ip} ${s2_port})
		if [ "${role_s1}" != master ] || [ "${role_s1}" = "${role_s2}" ]; then
			_send -h ${s1_ip} -p ${s1_port} REPLICAOF no one
			_send -h ${s2_ip} -p ${s2_port} REPLICAOF ${s1_ip} ${s1_port}
			role_s1=$(_get_role ${s1_ip} ${s1_port})
			role_s2=$(_get_role ${s2_ip} ${s2_port})
		fi
		_sleep ${time_check}
	done

else
	_exit
fi

_exit "[end]"
