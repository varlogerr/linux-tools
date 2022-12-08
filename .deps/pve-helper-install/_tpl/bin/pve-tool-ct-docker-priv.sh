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
    Prepare PRIVILEGED container for docker.
   .
    USAGE:
   .  ${TOOLNAME} [-h]
  "
}; trap_help_opt "${@}" && print_help && exit

ADD_CONF="
  lxc.apparmor.profile: unconfined
  lxc.cgroup.devices.allow: a
  lxc.cap.drop:
"

. "${INCDIR}/inc.change-conf.sh"
