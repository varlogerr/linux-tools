#!/usr/bin/env bash

TOOL_PATH="$(realpath -- "${BASH_SOURCE[0]}")"
BINDIR="$(realpath -- "$(dirname -- "${TOOL_PATH}")")"
INCDIR="$(realpath -- "${BINDIR}/../inc")"
TOOLNAME="$(basename "${TOOL_PATH}")"

. "${INCDIR}/lib.shlib.sh"

print_help() {
  text_decore "
    List available tools
   .
    USAGE:
   .  # -l, --list  Only list tools, without annotation
   .  ${TOOLNAME} [-h] [-l|--list]
  "
}; trap_help_opt "${@}" && print_help && exit

declare -A OPTS=(
  [list]=false
)

endopts=false; while :; do
  [[ -n "${1+x}" ]] || break
  ${endopts} && arg='*' || arg="${1}"

  case "${arg}" in
    --) endopts=true ;;
    -l|--list) OPTS[list]=true ;;
  esac

  shift
done

TOOLS_TXT="$(
  find "${BINDIR}" -mindepth 1 -maxdepth 1 -name '*.sh' \
  | sort -n | rev | cut -d'/' -f1 | rev
)"

mapfile -t TOOLS_LIST <<< "${TOOLS_TXT}"

if ${OPTS[list]}; then
  printf -- '%s\n' "${TOOLS_LIST[@]}"
else
  text_decore \
    "Available helpers:" \
    "$(printf -- '* %s\n' "${TOOLS_LIST[@]}")" \
    "Use \`TOOL -h\` for the tool help"
fi
