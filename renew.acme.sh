#!/bin/bash
# should be in /config/scripts/renew.acme.sh

DOMAIN=""
GLE_USER=""
GLE_KEY=""

usage() {
  echo "Usage: $0 -d <mydomain.com> [-d <additionaldomain.com>] -u <glesys-api-user> -k <glesys-api-key>" 1>&2
  exit 1
}

log() {
  if [ -z "$2" ]
  then
    printf -- "%s %s\n" "[$(date)]" "$1"
  fi
}

while getopts "hd:u:k:" opt; do
  case $opt in
    d) DOMAIN+=("$OPTARG");;
    u) GLE_USER=$OPTARG;;
    k) GLE_KEY=$OPTARG;;
    *) usage;;
  esac
done
shift $((OPTIND -1))

if [ ${#DOMAIN[@]} -eq 0 ] || [ -z $GLE_USER ] || [ -z $GLE_KEY ]; then
  usage
fi

for val in "${DOMAIN[@]}"; do
  if [ ! -z $val ]; then 
    DOMAINARG+="-d $val "
  fi
done

export GLE_USER
export GLE_KEY

ACMEHOME=/config/.acme.sh
EXEC_COMMAND="cat $ACMEHOME/${DOMAIN[0]}/${DOMAIN[0]}.cer $ACMEHOME/${DOMAIN[0]}/${DOMAIN[0]}.key > /config/ssl/server.pem; cp $ACMEHOME/${DOMAIN[0]}/ca.cer /config/ssl/ca.pem"

log "Starting ACME challenge service"
$ACMEHOME/acme.sh --issue \
  --dns dns_glesys \
  $DOMAINARG \
  --home $ACMEHOME \
  --reloadcmd "$EXEC_COMMAND" \
  --debug

if [ -e "/var/run/lighttpd.pid" ]; then
  log "Stopping gui service"
  kill -s INT $(pidof lighttpd) 2> /dev/null
fi

log "Starting gui service"
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf

unset GLE_USER
unset GLE_KEY
