#!/bin/sh
#
# settings
# file settings for sentinel
file_sentinel=/etc/sentinel.conf
# options: syslog or file
log=syslog
# syslog programe name
syslog_name=dump/mysqld
# file to log
file_log=S_PATH_LOG/mysql/dump.info
# debugging log (everything not empty)
debug=
# number of files to keep
files_max=10
# path to put mairiadb dump files
path2=${S_VM_PATH_SAVE}/mariadb
# name of hostname
hostname=${HOSTNAME}
# mariadb user to dump databases
db_user=dump

########################  FUNCTION

_log() { echo ${log_date}${id} $* | ${logcmd} >/dev/null; }
#_log_d() { echo ${log_date} ${id} debug $* >> ${file_log}; }
if [ -n "$debug" ]; then
	_log_d() { echo ${log_date}${id} debug $* | ${logcmd} >/dev/null; }
else
	_log_d() { :; }
fi
_exec() { test "$*" && _log_d "$*"; eval "$*"; }
_exit() { test "$*" && _log $*; exit 0; }
_exit_d() { test "$*" && _log_d $*; exit 0; }
_exit_e() { test "$*" && _log $*; exit 1; }

_rotate_files() {
	for ext in stru data; do
		for file in $(ls -1t ${path2} | grep "^${1}.*_${ext}.sql\(.gz\)\?$" -r | sed "1,${files_max} d"); do
			_exec rm ${path2}/${file}
		done
	done
}

########################  DATA

if [ "$log" = syslog ]; then
	logcmd="logger -p local7.info -t ${syslog_name}"
	log_date=
else
 	logcmd="tee -a ${file_log}"
	log_date="$(date "+%b %e %T") "
fi

########################  MAIN

# init log
[ "${log}" = file -a ! -d "${file_log%/*}" ] && mkdir -p ${file_log%/*}
# log arguments
_log_d "\$*=$*"
db_pwd=$1
path2=${2:-${path2}}
if [ -z "${db_user}" -o -z "${db_pwd}" -o -z "${path2}" ]; then
	_exit_e "data issue: db_user=${db_user} db_pwd=${db_pwd} path2=${path2}"
fi

# init path
[ -d "${path2}" ] || mkdir -p "${path2}"

# test connection
cmd="mysql -u$[db_user] -p${db_pwd} -e ''"
if ! [ "${cmd}" ]; then
	_exit_e "ERROR unable to connect to sgbd: db_user=${db_user} db_pwd=${db_pwd}"
	_log_d "${cmd}"
fi

# get list of db to dump
slave_state=$(mysql -u${db_user} -p${db_pwd} -e "SHOW SLAVE STATUS \G")
slave_do=$(echo "${slave_state}"|sed -n '/^\s*Replicate_Do_DB/ s|^.*:\s*\(.*\)$|\1|p'|tr ',' ' ')
slave_ignore=$(echo "${slave_state}"|sed -n '/^\s*Replicate_Ignore_DB/ s|^.*:\s*\(.*\)$|\1|p'|tr ',' ' ')
_log_d "slave_do=${slave_do}"
_log_d "slave_ignore=${slave_ignore}"

if [ "${slave_do}" ]; then
	db_names="${slave_do}"
else
	slave_all=$(mysql -BN -u${db_user} -p${db_pwd} -e "SHOW DATABASES"|xargs)
	_log_d "slave_all=${slave_all}"
	if [ "${slave_ignore}" ]; then
		db_names=" ${slave_all} "
		for str in ${slave_ignore} sys; do
			db_names="${db_names/ ${str} / }"
		done
	else
		db_names="${slave_all}"
	fi
fi
if [ -z "${db_names}" ]; then
	_log "WARNING No found databases to dump"
else
	_log "db_names=${db_names}"
fi

# dump & rotate
for db_name in ${db_names}; do
	file="${path2}/${hostname}_${db_name}_$(date +%Y%m%d-%H%M%S)"
	opts="-u${db_user} -p${db_pwd} ${db_name} --dump-slave --single-transaction" # options can be used : --dump-slave / 
	_log "dump - ${db_name}"
	_exec "mysqldump ${opts} --no-data | gzip -c > ${file}_stru.sql.gz"
	_exec "mysqldump ${opts} --no-create-info | gzip -c > ${file}_data.sql.gz"
	_log_d "dumped - ${db_name}"

	_rotate_files "${db_name}"
done
