# install tool specific libs
. "$(lt_dl ".deps/${LT_BASEDIR}/lib.main.sh" ".deps/${LT_BASEDIR}/lib.main.sh")"

trap_help_opt "${@}" && print_help && exit

SRC_INC_OPTS="$(lt_dl ".deps/${LT_BASEDIR}/inc.opts.sh" ".deps/${LT_BASEDIR}/inc.opts.sh")"
. "${SRC_INC_OPTS}" || trap_fatal $? "Can't source ${SRC_INC_OPTS}"

log_info "Checking prereqs ..."
pve_must_pve
pve_is_version7 || trap_fatal --decore $? "
  Unsupported pve version. Supported versions:
  * 7
"
sys_must_root
log_info "OK"

log_info ""
log_info "Configuration to be applied:"
for k in ${!OPTS[@]}; do
  printf '%s=%s\n' "${k}" "${OPTS[$k]}"
done | grep -E '^[[:upper:]]' | sort -n \
| sed 's/^/  /' | log_info

while ! ${OPTS[confirm]}; do
  read -p "Apply configuration [y/N]: " -r
  [[ "${REPLY,}" == y ]] && { OPTS[confirm]=true; continue; }
  [[ "${REPLY,}" == n ]] && exit
  [[ -z "${REPLY}" ]] && exit
  print_stderr "Invalid response!"
done

#
# ACTION
#

REBOOT_RECOMMENDED=false

if ${OPTS[PVE_DISABLE_ENTERPRISE_REPO]}; then
  log_info "Disabling enterprise repo ..."
  sleep 1

  pve_disable_enterprise_repo \
  && log_info "OK" \
  || log_warn "Failed!"
fi

if ${OPTS[PVE_ENABLE_NOSUBSCRIPTION_REPO]}; then
  log_info "Enabling no-subscription repo ..."
  sleep 1

  pve_enable_nosubscription_repo \
  && log_info "OK" \
  || log_warn "Failed!"
fi

if ${OPTS[PVE_DISABLE_SUBSCRIPTION_NAG]}; then
  log_info "Disabling subscription nag ..."
  sleep 1

  pve_disable_subscription_nag \
  && log_info "OK" \
  || log_warn "Failed!"
fi

if ${OPTS[FIX_GRUB_USB_ISSUE]}; then
  log_info "Fixing USB issue in GRUB ..."
  sleep 1

  sys_fix_grub_usb_issue \
  && {
    log_info "OK"
    REBOOT_RECOMMENDED=true
  } || log_warn "Failed!"
fi

if ${OPTS[PERFORM_UPGRADE]}; then
  log_info "Upgrading ..."
  sleep 1

  debian_upgrade \
  && {
    log_info "OK"
    REBOOT_RECOMMENDED=true
  } || log_warn "Failed!"
fi

if ${OPTS[PERFORM_CLEANUP]}; then
  log_info "Cleaning ..."
  sleep 1

  debian_cleanup \
  && log_info "OK" \
  || log_warn "Failed!"
fi

if ${REBOOT_RECOMMENDED} && ${OPTS[PERFORM_REBOOT]}; then
  log_info "Rebooting ..."
  sleep 1

  sys_reboot \
  && log_info "OK" \
  || log_warn "Failed!"
fi
