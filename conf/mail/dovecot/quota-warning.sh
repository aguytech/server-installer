#!/bin/sh

PERCENT=${1}
USER=${2}

CMD=`find /usr -name dovecot-lda`

if [ "${CMD}" ]; then
  cat << EOF | ${CMD} -d ${USER} -o "plugin/quota=maildir:User quota:noenforcing"
From: no-reply@_MEL_DOM_FQDN
Subject: [Postmaster] Votre Boîte de courrier est pleine à ${PERCENT}%
Content-Type: text/plain; charset="utf-8"

Votre Boîte de courrier est pleine à ${PERCENT}%
Contactez votre administrateur ou faites du ménage dans votre boîte:
${USER}
EOF

else

  cat << EOF | ${CMD} -d postmaster@_MEL_DOM_FQDN -o "plugin/quota=maildir:User quota:noenforcing"
From: root@_MEL_DOM_FQDN
Subject: [Error] Unable to find ${CMD}
Content-Type: text/plain; charset="utf-8"

Unable to find command:${CMD}
from hostname: `hostname`
EOF
fi
