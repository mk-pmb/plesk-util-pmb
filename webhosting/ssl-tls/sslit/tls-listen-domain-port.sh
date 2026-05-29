#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function tlslisten_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local DBGLV="${DEBUGLEVEL:-0}"

  local DOMAIN="${1:-none.test}"; shift
  local LSN_PORT="$1"; shift

  local KEYS_DIR='/opt/psa/var/modules/sslit/etc/live'
  cd -- "$KEYS_DIR" || return 4$(
    echo E: "Failed to chdir to $KEYS_DIR, maybe try with sudo?" >&2)
  cd -- "$DOMAIN" || return 4$(
    echo E: "Failed to chdir from $PWD to domain subdirectory (CLI arg 1)" \
      "'$DOMAIN', maybe try one of these? $(echo [a-z]*.*/ | tr -d /)" >&2)
  KEYS_DIR="$PWD"

  LSN_PORT="${LSN_PORT//[^0-9]/}"
  while [ "${LSN_PORT:0:1}" == 0 ]; do LSN_PORT="${LSN_PORT:1}"; done
  [ "${LSN_PORT:-0}" -ge 1 ] || return 4$(
    echo E: 'Listening port (CLI arg 2) must be a positive integer.' >&2)

  cd / || return 4$(
    echo E: 'Failed to chdir to /. Your system seems REALLY broken!' >&2)

  if [ "$1" == --crlf ]; then
    exec < <(sed -ure 's~$~\r~')
    shift
  fi

  local LSN_SOCK="openssl-listen:$LSN_PORT"
  LSN_SOCK+=',reuseaddr,fork'
  LSN_SOCK+=",cert=$KEYS_DIR/fullchain.pem"
  LSN_SOCK+=",key=$KEYS_DIR/privkey.pem"
  LSN_SOCK+=",verify=0"

  local OPT=
  [ "$DBGLV" -lt 4 ] || OPT+=' -d -d'

  set -- socat $OPT "$LSN_SOCK" STDIO
  [ "$DBGLV" -lt 2 ] ||
    echo D: "Gonna listen on TCP $DOMAIN:$LSN_PORT with TLS:" >&2
  [ "$DBGLV" -lt 3 ] || echo D: "run: $*" >&2
  exec "$@"
}










tlslisten_cli_init "$@"; exit $?
