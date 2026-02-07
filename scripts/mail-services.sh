#!/usr/bin/env bash
reverse_services() {
        local MIN=0
        local MAX=$(( ${#SERVICES[@]} - 1 ))
        while [[ MIN -lt MAX ]]; do
                X="${SERVICES[$MIN]}"
                SERVICES[MIN]="${SERVICES[$MAX]}"
                SERVICES[MAX]="${X}"
                (( MIN++, MAX-- ))
        done
}
SERVICES=(postfix dovecot sogod spamass-milter sa-spamd postgresql slapd coredns clamav-milter clamav-freshclam clamav-clamd)
OPERATION="noop"
if [ -n "$1" ]; then
        if [ "$1" == "--start" ]; then
                reverse_services
                OPERATION="start"
        elif [ "$1" == "--stop" ]; then
                OPERATION="stop"
        fi
fi
if [ "$OPERATION" == "noop" ]; then
        echo "nothing to do."
        exit 0
fi
for SERVICE_NAME in "${SERVICES[@]}"; do
        echo "service ${SERVICE_NAME} ${OPERATION}"
done
