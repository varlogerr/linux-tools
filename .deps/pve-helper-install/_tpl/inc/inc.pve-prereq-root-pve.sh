log_info "Checking prereqs ..."
pve_must_pve
pve_is_version7 || trap_fatal --decore $? "
  Unsupported pve version. Supported versions:
  * 7
"
sys_must_root
log_info "OK"
