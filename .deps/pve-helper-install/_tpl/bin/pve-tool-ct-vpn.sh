#!/usr/bin/env bash

TOOL_PATH="$(realpath -- "${BASH_SOURCE[0]}")"
BINDIR="$(realpath -- "$(dirname -- "${TOOL_PATH}")")"
INCDIR="$(realpath -- "${BINDIR}/../inc")"
TOOLNAME="$(basename "${TOOL_PATH}")"

. "${INCDIR}/lib.shlib.sh"
. "${INCDIR}/lib.ct.sh"
. "${INCDIR}/lib.pve.sh"
. "${INCDIR}/lib.sys.sh"

print_help() {
  text_decore "
    Prepare (un-)privileged container for vpn server.
   .
    USAGE:
   .  ${TOOLNAME} [-h]
  "
}; trap_help_opt "${@}" && print_help && exit

TUN_UID="$(grep -E '^root:' /etc/subuid 2>/dev/null | tail -n 1 | cut -d: -f2)" \
  || trap_fatal "Can't detect subuid"
TUN_GID="$(grep -E '^root:' /etc/subgid 2>/dev/null | tail -n 1 | cut -d: -f2)" \
  || trap_fatal "Can't detect subgid"

VPN_TUN_FILE=/dev/net/tun
VPN_TUN_APPLY_TXT="
  Filesystem changes can be applied with:
 .  set -x; chown '${TUN_UID}:${TUN_UID}' '${VPN_TUN_FILE}'
"
VPN_TUN_REVERT_TXT="
  Filesystem changes can be restored with:
 .  set -x; chown 'root:root' '${VPN_TUN_FILE}'
"

ADD_CONF="
  lxc.mount.entry: /dev/net dev/net none bind,create=dir
  lxc.cgroup2.devices.allow: c 10:200 rwm
"

conf_before_change() {
  local id="${1}"
  local conffile="${2}"

  ( set -x; chown "${TUN_UID}:${TUN_GID}" "${VPN_TUN_FILE}" ) \
  || trap_fatal --decore 1 "Can't chown ${VPN_TUN_FILE}"
}

conf_after_change() {
  text_decore "${VPN_TUN_REVERT_TXT}" | log_warn
}

conf_before_merge_noneed() {
  text_decore "${VPN_TUN_APPLY_TXT}" "${VPN_TUN_REVERT_TXT}" | log_warn
}

. "${INCDIR}/inc.change-conf.sh"
