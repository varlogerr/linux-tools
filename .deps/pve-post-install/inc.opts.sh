declare -A OPTS=(
  [mode]=
  [file]=
  [confirm]=false
)

endopts=false
while :; do
  [[ -n "${1+x}" ]] || break
  ${endopts} && arg='*' || arg="${1}"

  case "${arg}" in
    --) endopts=true ;;
    -y|--yes) OPTS[confirm]=true ;;
    --conf-gen)
      OPTS[mode]=conf-gen
      [[ -n "${2+x}" ]] && {
        shift
        OPTS[file]="${1}"
      }
      ;;
    --reboot) OPTS[PERFORM_REBOOT]=true ;;
    *) OPTS[file]="${1}"
  esac

  shift
done

[[ (-n "${OPTS[file]}" && -z "${OPTS[mode]}" ) ]] && OPTS[mode]=run

[[ -z "${OPTS[mode]}" ]] && trap_fatal --decore 1 "
  Invalid or not enough input. To get help issue:
 .  ${LT_TOOLNAME} -h
"

if [[ "${OPTS[mode]}" == conf-gen ]]; then
  if [[ -f "${OPTS[file]}" ]]; then
    while ! ${OPTS[confirm]}; do
      read -p "Override existing ${OPTS[file]} [y/N]: " -r
      [[ "${REPLY,}" == y ]] && { OPTS[confirm]=true; continue; }
      [[ "${REPLY,}" == n ]] && exit
      [[ -z "${REPLY}" ]] && exit
      print_stderr "Invalid response!"
    done
  fi

  OPTS[file]="${OPTS[file]:-/dev/stdout}"
  dest_dir="$(dirname "${OPTS[file]}")"
  mkdir -p "${dest_dir}" 2>/dev/null || trap_fatal $? "Can't create directory: ${dest_dir}"
  print_opts_txt 2>/dev/null > "${OPTS[file]}" || trap_fatal $? "Can't write to rile: ${OPTS[file]}"
  exit
fi

conffile_content="$(cat -- "${OPTS[file]}" 2>/dev/null)" || trap_fatal $? "Can't read the file: ${OPTS[file]}"
conffile_content="$(
  grep -v '^\s*$' <<< "${conffile_content}" \
  | sed -e 's/^\s\+//g' -e 's/\s\+$//g' \
  | grep -v '^\s*#'
)"
req_fields="$(print_opts_txt | grep -v '^\s*#' | cut -d= -f1)"
conffile_fields="$(cut -d= -f1 <<< "${conffile_content}")"

absent_fields="$(echo "${req_fields}" | grep -vFx -f <(echo "${conffile_fields}"))" \
&& trap_fatal --decore 1 "
  Missing fields in ${OPTS[file]}:
  $(sed 's/^/* /' <<< "${absent_fields}")
"
redundant_fields="$(echo "${conffile_fields}" | grep -vFx -f <(echo "${req_fields}"))" \
&& trap_fatal --decore 1 "
  Missing fields in ${OPTS[file]}:
  $(sed 's/^/* /' <<< "${redundant_fields}")
"

declare -a inval=()
mapfile -t fields < <(sed 's/$/=/' <<< "${conffile_content}")
for f in "${fields[@]}"; do
  key="$(cut -d= -f1 <<< "${f}")"
  val="$(cut -d= -f2- <<< "${f}" | sed 's/=$//')"
  OPTS[${key}]="${OPTS[${key}]:-${val}}"
  check_bool "${val}" || inval+=("$(sed 's/=$//' <<< "${f}")")
done

[[ "${#inval[@]}" -lt 1 ]] || trap_fatal $? --decore "
  Invalid values for fields:
  $(printf -- '* %s\n' "${inval[@]}")
"

declare -A risky_opts=(
  [FIX_GRUB_USB_ISSUE]="Affects GRUB configuration"
  [PERFORM_REBOOT]="Can interrupt somebody's work"
)
declare -A risky_changes
for k in "${!risky_opts[@]}"; do
  ${OPTS[$k]} && risky_changes+=([${k}]="${risky_opts[$k]}")
done

[[ ${#risky_changes[@]} -gt 0 ]] && {
  echo "Potentially risky changes:"
  for k in "${!risky_changes[@]}"; do
    echo "* ${k} - ${risky_changes[$k]}"
  done | sort -n
} | print_stderr
