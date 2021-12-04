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

. /server/server.conf
. /server/install.conf
. /server/lxd.conf
. /server/mail-ambau.ovh.lxd.conf
_DATE=`date "+%Y%m%d"`
_SDATE=`date +%s`
_CIDR_VM=`sed -n 's|.* s_cidr=\([^ ]*\).*|\1|p' <<<${S_HOST_VM_ETH[default]}`
_IPS_CLUSTER=`tr ' ' '\n' <<<${S_CLUSTER[*]} | sed -n 's|^s_ip=\([^ ]*\)|\1|p' | xargs`
_IPS_AUTH=`printf "%q\n" ${S_IPS_ADMIN} ${S_IPS_DEV} | sort -u | xargs`
