#!/usr/bin/env bash
set -euo pipefail
USERLIST=(alan carrie)
for UNAME in "${USERLIST[@]}}"; do
    SHORT_TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_FILE="/var/mail/backup/${UNAME}_Maildir_${SHORT_TIMESTAMP}.tar.bz2"
    if [ -f "${BACKUP_FILE}" ]; then
      mv "${BACKUP_FILE}" "${BACKUP_FILE}_$$"
    fi
    doveadm backup -u "${UNAME}" maildir:~/Maildir
    pushd "/home/${UNAME}" && tar cfj "${BACKUP_FILE}" Maildir && chown mailbackup:mailbackup "${BACKUP_FILE}"
    popd || exit
done
