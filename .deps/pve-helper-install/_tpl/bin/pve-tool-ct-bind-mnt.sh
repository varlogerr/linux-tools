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
    Bind mount a directory to an LXC confainer.
    Mount format: <HOST_VOLUME>:<CT_MOUNT_POINT>
   .
    USAGE:
   .  ${TOOLNAME} -h
   .  # Read bind map list from a file, one item per line.
   .  # '#'-prefixed and empty lines are ignored
   .  ${TOOLNAME} CONFFILE_PATH
   .
    DEMO:
   .  ${TOOLNAME} <(echo '
   .    # my precious data holder
   .    /mnt/data-disk:/mnt/data
   .    # my precious data guard
   .    /mnt/backup-disk:/mnt/backups
   .  ')
  "
}; trap_help_opt "${@}" && print_help && exit

file_content="$(timeout 2 cat -- "${1--}" 2>/dev/null)" \
|| trap_fatal $? "Can't read file: ${1}"

mnt_list="$(text_rmblank "${file_content}" | text_trim | grep -v '^\s*#')" \
|| trap_fatal $? "No mounts detected in: ${1}"

# compose config
ADD_CONF=""
declare -a INVAL_FORM
declare -a mnt_arr; mapfile -t mnt_arr <<< "${mnt_list}"
for ix in "${!mnt_arr[@]}"; do
  item="${mnt_arr[$ix]}"
  volume="$(cut -d: -f1 <<< "${item}")"
  mp="$(cut -d: -f2 <<< "${item}:")"

  [[ "${volume:0:1}" == '/' ]] || { INVAL_FORM+=("${item}"); continue; }
  [[ "${mp:0:1}" == '/' ]] || { INVAL_FORM+=("${item}"); continue; }

  ADD_CONF+="${ADD_CONF:+$'\n'}mp${ix}: ${volume},mp=${mp}"
  ADD_CONF+=",mountoptions=noatime,replicate=0,backup=0"
done

# validation
[[ ${#INVAL_FORM} -lt 1 ]] || trap_fatal --decore $? "
  Invalid mount items:
  $(printf -- '* %s\n' "${INVAL_FORM[@]}")
 .
  See help:
 .  ${TOOLNAME} -h
"

. "${INCDIR}/inc.change-conf.sh"
