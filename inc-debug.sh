#!/bin/bash

white='\e[0;0m'; red='\e[0;31m'; green='\e[0;32m'; blue='\e[0;34m'; magenta='\e[0;95m'; yellow='\e[0;93m'; cyan='\e[0;96m';
whiteb='\e[1;1m'; redb='\e[1;31m'; greenb='\e[1;32m'; blueb='\e[1;34m'; magentab='\e[1;95m'; yellowb='\e[1;93m'; cyanb='\e[1;96m'; cclear='\e[0;0m';
_echo() { echo -e "$*"; }
_echO() { echo -e "${whiteb}$*${cclear}"; }
_echo_() { echo -e $*; }
_echO_() { echo -e ${whiteb}$*${cclear}; }
# debug
_echod() { echo "$(date +"%Y%m%d %T") $*"; }
# alert
_echoa() { echo -e "${yellow}$*${cclear}"; }
_echoA() { echo -e "[alert] ${yellowb}$*${cclear}"; }
# warnning
_echow() { echo -e "${magenta}$*${cclear}"; }
_echoW() { echo -e "${magentab}$*${cclear}"; }
# error
_echoe() { echo -e "${red}$*${cclear}"; }
_echoE() { echo -e "${redb}$*${cclear}"; }
# information
_echoi() { echo -e "$*" >&4; }
_echoI() { echo -e "${yellowb}$*${cclear}"; }
# title
_echot() { echo -e "${cyan}$*${cclear}"; }
_echoT() { echo -e "${cyanb}$*${cclear}"; }
_ask() { _ANSWER=; while [ -z "$_ANSWER" ]; do _echo_ -n "$*: "; read _ANSWER; _echod; done; }
_askno() { _ANSWER=; _echo_ -n "$*: "; read _ANSWER; _echod; }
_askyn() { local options; _ANSWER=; options=" y n "; while [ "${options/ $_ANSWER }" = "$options" ]; do _echo_ -n "$* (y/n): "; read _ANSWER;     _echod; done; }
_pwd() { < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c14; }
_lxc_exec() { local ct=$1 && shift; lxc exec ${ct} -- sh -c "$*"; }
_lxc_exec_e() { local ct=$1 && shift; lxc exec ${ct} -- sh -c "$*" || echo "Unable to execute on ${ct}: $*"; }
_var_replace_vars() {
    local vars

        case $1 in
            apache)
                vars="S_VM_PATH_SHARE S_RSYSLOG_PTC S_RSYSLOG_PORT _DOM_FQDN _IPTHIS _IPS_AUTH _APA_PATH_WWW _APA_DOM_ADMIN _APA_SUB _CIDR_VM" ;;
            apache2)
                vars="_APA_TIMEOUT _APA_KEEPALIVE_TIME _APA_KEEPALIVE_REQUEST _APA_KEEPALIVE_TIMEOUT S_EMAIL_ADMIN _APA_START_SERVERS _APA_MIN_SPARE_THREADS _APA_MAX_SPARE_THREADS _APA_THREADS_PER_CHILD _APA_MAX_REQUEST_WORKERS _APA_MAX_CONNECTIONS_PER_CHILD" ;;
            fail2ban)
                vars="S_DOM_FQDN S_EMAIL_TECH S_HOST_PATH_LOG _IPS_IGNORED _SSH_PORT" ;;
            haproxy)
                vars="S_RSYSLOG_PORT S_SERVICE[mail] S_EMAIL_ADMIN _SOMAXCONN _HPX_PATH_SSL _HPX_CERTBOT_PORT _HPX_STATS_PORT _HPX_STATS_2_PORT S_DOM_FQDN S_DOM_NAME _HPX_CT_NAME _HPX_ACCESS_USER _HPX_ACCESS_PWD _HPX_ACCESS_URI _HPX_DNS_DEFAULT _SERVER_DEFAULT" ;;
            logrotate)
                vars="S_PATH_LOG S_HOST_PATH_LOG S_VM_PATH_LOG S_PATH_LOG_INSTALL S_PATH_LOG_SERVER" ;;
            mail)
                vars="S_SERVICE[mail] S_PATH_CONF S_DOM_FQDN S_EMAIL_TECH S_EMAIL_ADMIN _MEL_PATH_SQL _MEL_PATH_SSL _MEL_PATH_VMAIL _MEL_PATH_LOCAL _MEL_PATH_SIEVE _MEL_DB_HOST _MEL_DB_NAME _MEL_DB_USER _MEL_DB_PWD _MEL_SSL_SCHEME _MEL_DB_PFA_USER _MEL_DB_PFA_PWD _MEL_CIDR _IPS_CLUSTER _MEL_VMAIL_USER _MEL_VMAIL_UID" ;;
            rspamd)
                vars="S_RSPAMD_PORT[proxy] S_RSPAMD_PORT[normal] S_RSPAMD_PORT[controller] S_CACHE_PORT S_CACHE_READ_PORT _MEL_CTS_RDS _IPS_CLUSTER _MEL_CIDR _MEL_PATH_SPAM _MEL_PATH_DKIM" ;;
            mariadb)
                vars="S_DB_MARIA_PORT _MDB_VM_PATH _MDB_PATH_BINLOG _MDB_PATH_LOG _MDB_MAX_BIN_SIZE _MDB_EXPIRE_LOGS_DAYS _MDB_MASTER_ID _MDB_SLAVE_ID _MDB_REPLICATE_EXCEPT _MDB_REPLICATE_ONLY" ;;
            php)
                vars="_PHP_SERVICE _PHP_FPM_SOCK _PHP_FPM_ADMIN_SOCK _IP_HOST_VM" ;;
            pma)
                vars="_APP_URI _PMA_HOST _APP_DB_PORT _APP_DB_USER _APP_DB_PWD _APP_BLOWFISH _APP_PATH_UP _APP_PATH_DW" ;;
            redis)
                vars="S_PATH_LOG S_CACHE_PORT S_CACHE_READ_PORT _RDS_PATH_LIB _RDS_CT_NAME _RDS_QUORUM _RDS_DOWN _RDS_FAILOVER _RDS_BACKLOG _RDS_TIMEOUT _RDS_KEEPALIVE _RDS_MEM_MAX _RDS_MEM_POL _RDS_DATABASES _RDS_LOGLEVEL _RDS_PROXY" ;;
            rsyslog)
                vars="S_SERVICE[log] S_SERVICE[mail] S_PATH_LOG S_HOST_PATH_LOG S_VM_PATH_LOG S_RSYSLOG_PORT S_RSYSLOG_PTC" ;;
            script)
                vars="S_PATH_SCRIPT" ;;
            *)
                _exite "${FUNCNAME} Group: '${opt}' are not implemented yet" ;;
        esac

    echo ${vars}
}
_var_replace() {
    local file opt var
    [ "$#" -lt 2 ] && echo "${FUNCNAME}:${LINENO} Wrong parameters numbers (2): $#"
    file=$1; shift
    for opt in $*; do
        for var in `_var_replace_vars ${opt}`; do
            _evalr "sed -i 's|${var/[/\\[}|${!var}|g' '${file}'"
            #'\\]}"
        done
    done
}
_lxc_var_replace() {
    local file opt var ct
    ct=$1; shift; file=$1; shift;
    for opt in $*; do
        for var in `_var_replace_vars ${opt}`; do
            var2="${var/[/\\[}"; var2="${var2/]/\\]}"   #"\\]}"
            _lxc_exec ${ct} "grep -q '${var2}' -r ${file} && grep '${var2}' -rl ${file} | xargs sed -i 's|${var2}|${!var}|g'"
        done
    done
}

_menu() {
    PS3="$1: "
    shift
    echo "——————————————————————"
    select _ANSWER in $*; do
        [ "${_ANSWER}" ] && break || echo -e "\nTry again"
    done
}
_menua() {
    PS3="$1 (by toggling options): "
    shift
    ansmenu="valid $* "
    local anstmp
    anstmp=
    while [ "${anstmp}" != valid ]; do
        echo "——————————————————————"
        select anstmp in ${ansmenu}; do [ "${anstmp::2}" == ++ ] && ansmenu=${ansmenu/ ${anstmp} / ${anstmp#++} } || ansmenu=${ansmenu/ ${anstmp} / ++${anstmp} }; break; done
    done
    ansmenu=${ansmenu#valid }
    _ANSWER=$(echo ${ansmenu}|tr ' ' '\n'|sed -n '/^++/ s|++||p')
}

alias _eval=eval
alias _evalq=eval
alias _evalr="eval sudo"
alias _evalrq="eval sudo"

alias _confset=echo

. /server/server.conf
. /server/install.conf
. /server/lxd.conf
_DATE=`date "+%Y%m%d"`
_SDATE=`date +%s`
_CIDR_VM=`sed -n 's|.* s_cidr=\([^ ]*\).*|\1|p' <<<${S_HOST_VM_ETH[default]}`
_IPS_CLUSTER=`tr ' ' '\n' <<<${S_CLUSTER[*]} | sed -n 's|^s_ip=\([^ ]*\)|\1|p' | xargs`
_IPS_AUTH=`printf "%q\n" ${S_IPS_ADMIN} ${S_IPS_DEV} | sort -u | xargs`
