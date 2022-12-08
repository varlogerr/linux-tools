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
  unnag_script_path="$(lt_dl .deps/pve-post-install/_tpl/pve-unnag-script.txt \
    .deps/pve-post-install/_tpl/pve-unnag-script.txt)" 2>/dev/null || return 1
  (
    set -x
    /bin/cp -f "${unnag_script_path}" "${dest}" 2>/dev/null \
    && apt --reinstall install proxmox-widget-toolkit &>/dev/null
  ) || return 1
}

# Merge SRC_CONF_TXT with NEW_CONF_TXT
#   ct_conf_merge SRC_CONF_TXT NEW_CONF_TXT # => MERGED_CONF_TXT
# RC:
# * 0 - something is merged
# * 1 - nothing new is merged
pve_conf_merge() {
  local src_conf_txt="${1}"; src_conf_txt="$(text_trim "${src_conf_txt}")"
  local replace_txt="${2}"; replace_txt="$(text_trim "${replace_txt}" | text_rmblank)"
  local new_conf_txt="${src_conf_txt}"
  local rc=1
  local current_conf_txt="${src_conf_txt}"
  local snapshots_conf_txt

  declare -a replace_arr; mapfile -t replace_arr <<< "${replace_txt}"
  [[ -n "${replace_txt}" ]] || replace_arr=()

  local snapshot_line
  snapshot_line="$(grep -n '^\s*\[' <<< "${src_conf_txt}")" && {
    local line_no="$(head -n 1 <<< "${snapshot_line}" | cut -d: -f 1)"
    current_conf_txt="$(head -n $(( line_no - 1 )) <<< "${src_conf_txt}" | text_rmblank)"
    snapshots_conf_txt="$(tail -n +${line_no} <<< "${src_conf_txt}")"
  }

  local key
  local val
  local key_rex
  local val_rex
  local line; for line in "${replace_arr[@]}"; do
    key="$(sed -e 's/^\([^:=]\+\)[:=].*/\1/' <<< "${line}" | text_trim)"
    val="$(sed -e 's/^[^:=]\+[:=]\(.*\)/\1/' <<< "${line}" | text_trim)"
    key_rex="$(sed_quote_pattern "${key}")"
    val_rex="$(sed_quote_pattern "${val}")"

    grep -q "^${key_rex}\s*[:=]\s*${val_rex}\s*" <<< "${current_conf_txt}" && continue

    rc=0
    grep -q "^${key_rex}\s*[:=]" <<< "${current_conf_txt}" || {
      current_conf_txt+="${current_conf_txt:+$'\n'}${key}: ${val}"
      continue
    }

    current_conf_txt="$(
      sed -e 's/^\('"${key_rex}"'\)\s*[:=].*/\1: '"$(
        sed_quote_replace "${val}"
      )"'/' <<< "${current_conf_txt}"
    )"
  done

  echo "${current_conf_txt}${snapshots_conf_txt:+$'\n'$'\n'}${snapshots_conf_txt}"
  return $rc
  # local new_keys_rex
  # new_keys_rex="$(
  #   sed -e 's/^\([^:=]\+\)[:=].*/\1/'
  #     -e 's/\./\\&/g' -e 's/^/^\\s*/'
  #     -e 's/$/:/' <<< "${new_conf_txt}"
  # )"

  # echo "${new_keys_rex}"
}
