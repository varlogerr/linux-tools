pve_is_version7() {
  pveversion 2>/dev/null | grep -qF 'pve-manager/7'
}

pve_must_pve() {
  pveversion &>/dev/null \
  || trap_fatal $? 'No pve detected!'
}

pve_disable_enterprise_repo() {
  (
    set -x
    sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/pve-enterprise.list &>/dev/null
  )
}

pve_enable_nosubscription_repo() {
  local repo="deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription"
  local dest_file=/etc/apt/sources.list.d/pve-no-subscription.list
  echo "${repo}" 2>/dev/null > "${dest_file}"
}

pve_disable_subscription_nag() {
  local dest=/etc/apt/apt.conf.d/no-nag-script
  local unnag_script_path

  [[ -f "${dest}" ]] && return
  unnag_script_path="$(lt_dl .deps/_tpl/pve-unnag-script.txt .deps/_tpl/pve-unnag-script.txt)" 2>/dev/null || return 1
  (
    set -x
    /bin/cp -f "${unnag_script_path}" "${dest}" 2>/dev/null \
    && apt --reinstall install proxmox-widget-toolkit &>/dev/null
  ) || return 1
}
