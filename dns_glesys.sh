#!/usr/bin/env bash
# should be in /config/.acme.sh/dns_glesys.sh

set -e

GLE_USER="${GLE_USER:-}"
GLE_KEY="${GLE_KEY:-}"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PY="${DIR}/parse.py"
API_BASE="https://api.glesys.com/domain"

dns_glesys_add() {
  fulldomain=$1
  txtvalue=$2

  domainname=$(echo ${1}|sed -E 's/^.*\.+([a-z]+\.[a-z]+) {0,}$/\1/i')

  echo `_clear_records $domainname`
  echo `_add_record $domainname $fulldomain $txtvalue`

  return 0
}

dns_glesys_rm() {
  fulldomain=$1
  txtvalue=$2

  domainname=$(echo ${1}|sed -E 's/^.*\.+([a-z]+\.[a-z]+) {0,}$/\1/i')

  recordid=$(_list $domainname|eval $PY "record" "${txtvalue}")

  if [ -z $recordid ]; then
    return 1
  fi

  _del_record $recordid

  return 0
}

_post() {
  curl -X POST -s --basic -u "${GLE_USER}:${GLE_KEY}" $@
}

_list() {
  domainname=$1
  _post --data-urlencode "domainname=${domainname}" "${API_BASE}/listrecords"
}

_del_record() {
  recordid=$1

  echo -e "_del_record: ${recordid}\n"

  _post --data-urlencode "recordid=${recordid}" "${API_BASE}/deleterecord"
}

_add_record() {
  domainname=$1
  fulldomain=$2
  txtvalue=$3

  _post --data-urlencode "domainname=${domainname}" \
    --data-urlencode "host=${fulldomain}" \
    --data-urlencode "type=TXT" \
    --data-urlencode "data=${txtvalue}" \
     "${API_BASE}/addrecord"
}

_clear_records() {
  domainname=$1
  for i in $(_list $domainname|eval $PY "records");
  do
    _del_record $i
  done
}
