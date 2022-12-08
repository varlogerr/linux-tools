#
# Expects to have ADD_CONF variable with the text like
# ```
# ADD_CONF="
#   lxc.apparmor.profile: unconfined
#   lxc.cgroup.devices.allow: a
#   lxc.cap.drop:
# "
# ```
# Available hooks:
# * conf_before_merge_noneed ID CONF_PATH
# * conf_before_change ID CONF_PATH
# * conf_after_change ID CONF_PATH
#

. "${INCDIR}/inc.pve-prereq-root-pve.sh"

declare -A OPTS=(
  [confirm]=false
  [id]=
  [conffile]=
)

. "${INCDIR}/inc.ct-read-id.sh"

OPTS[conffile]="/etc/pve/lxc/${OPTS[id]}.conf"
[[ -f "${OPTS[conffile]}" ]] || trap_fatal $? "
  Can't detect conffile at: ${OPTS[conffile]}
"

CONFFILE_TXT="$(cat -- "${OPTS[conffile]}" 2>/dev/null)" \
|| trap_fatal $? "Can't read conffile: ${OPTS[conffile]}"

text_decore "
  Container: $(ct_get_id_name_by_id "${OPTS[id]}")
  Config file: ${OPTS[conffile]}
" | log_info

ct_check_id "${OPTS[id]}" || trap_fatal $? "
  Invalid LXC container ID: ${OPTS[id]}
"

NEW_CONFFILE_TXT="$(pve_conf_merge "${CONFFILE_TXT}" "${ADD_CONF}")" || {
  if declare -F conf_before_merge_noneed &> /dev/null; then
    conf_before_merge_noneed "${OPTS[id]}" "${OPTS[conffile]}"
  fi
  text_decore "
    No changes to be applied to ${OPTS[conffile]}
    Old configuration can be restored by removing the lines:
    $(text_decore "${ADD_CONF}" | sed 's/^/.  /')
  " | log_warn
  exit
}

{
  text_decore "
    The configuration file will be overriden with
    the following (${OPTS[conffile]}):
  "
  sed 's/^/  /' <<< "${NEW_CONFFILE_TXT}"
} | log_info

while ! ${OPTS[confirm]}; do
  read -p "Confirm [y/N]: " -r
  [[ "${REPLY,}" == y ]] && { OPTS[confirm]=true; continue; }
  [[ "${REPLY,}" == n ]] && exit
  [[ -z "${REPLY}" ]] && exit
  print_stderr "Invalid response!"
done

ct_check_id "${OPTS[id]}" || trap_fatal $? "
  Invalid LXC container ID: ${OPTS[id]}
"

if declare -F conf_before_change &> /dev/null; then
  conf_before_change "${OPTS[id]}" "${OPTS[conffile]}"
fi

/bin/cp -f "${OPTS[conffile]}" "${OPTS[conffile]}.bak" 2>/dev/null \
|| trap_fatal $? "Can't backup file: ${OPTS[conffile]}"

(
  set -o pipefail
  set -x
  cat <<< "${NEW_CONFFILE_TXT}" | tee "${OPTS[conffile]}" &>/dev/null
) || trap_fatal $? "Error applying configuration"

if declare -F conf_after_change &> /dev/null; then
  conf_after_change "${OPTS[id]}" "${OPTS[conffile]}"
fi

text_decore "
  Compare old configuration with the new one:
 .  diff --side-by-side '${OPTS[conffile]}.bak' '${OPTS[conffile]}' | less
  Restore old configuration with:
 .  /bin/cp -f '${OPTS[conffile]}.bak' '${OPTS[conffile]}'
" | log_warn
