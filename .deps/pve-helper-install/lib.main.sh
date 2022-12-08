print_help() {
  text_decore "
    Install PVE-related helpers and make them
    available for the current user. All the
    tools are prefixed with 'pve-tool-'. The
    installation doesn't require sudo. For the
    current user the tools will be installed
    to the following directory:
   .  ${HOME}/${LT_DIR_PREFIX_USER_TOOLS}/pve-helper
   .
    USAGE:
   .  # Install PVE helpers
   .  ${LT_TOOLNAME} [-y|--yes]
   .
    Development:
    * LT_BRANCH   Env var to manipulate with branch
  "
}

bundle_make() {
  local home_url="https://github.com/varlogerr/linux-tools/archive/refs/heads"
  local tmp_file
  local workdir
  tmp_file="$(LT_HOMEURL="${home_url}" lt_dl "${LT_BRANCH}.tar.gz" bundle.tar.gz)"
  workdir="$(dirname -- "${tmp_file}" 2>/dev/null)"

  local bundle_dir; bundle_dir="${workdir}/linux-tools-${LT_BRANCH}"
  local cp_dir; cp_dir="${workdir}/pve-helper"

  tar -xf "${tmp_file}" -C "${workdir}" &>/dev/null || return $?
  mkdir -p "${cp_dir}" &>/dev/null || return $?
  mv "${bundle_dir}/.deps/${LT_BASEDIR}/_tpl"/* "${cp_dir}"/ 2>/dev/null || return $?
  mv "${bundle_dir}/.deps"/lib.*.sh "${cp_dir}/inc" 2>/dev/null || return $?
  mv "${bundle_dir}/proxmox"/*.sh "${cp_dir}/bin" 2>/dev/null || return $?
  mv "${bundle_dir}/.deps/_mix/pathadd.sh" "${cp_dir}/pathadd.sh" 2>/dev/null || return $?
  chmod 0755 "${cp_dir}/bin"/*.sh &>/dev/null || return $?

  rm "${tmp_file}" 2>/dev/null
  rm -rf "${bundle_dir}" 2>/dev/null

  echo "${cp_dir}"
}

configure_path() {
  local main_src_entry=". ~/${OPTS[dest_prefix]}/pathadd.sh"
  local user_src_entry=". ~/${LT_DIR_PREFIX_MAIN_PATHADD}"

  if ! grep -Fxq "${main_src_entry}" ~/"${LT_DIR_PREFIX_MAIN_PATHADD}" 2>/dev/null; then
    (
      set -x; echo "${main_src_entry}" \
      | tee -a ~/"${LT_DIR_PREFIX_MAIN_PATHADD}" &>/dev/null
    ) || return $?
  fi

  local bashrc="$(cat ~/.bashrc 2>/dev/null | sed -e 's/^\s\+//' -e 's/^\s\+//')"
  if ! grep -Fxq "${user_src_entry}" <<< "${bashrc}" 2>/dev/null; then
    (
      set -x; echo "${user_src_entry}" | tee -a ~/.bashrc &>/dev/null
    ) || return $?
  fi
}

install_helpers() {
  local bundle_dir; bundle_dir="$(bundle_make)" || return $?

  (set -x; mkdir -p "${OPTS[dest]}" &>/dev/null) || return $?
  (
    set -x
    cd "${bundle_dir}" 2>/dev/null \
    && cp -R ./* "${OPTS[dest]}"/ 2>/dev/null
  ) || return $?
  rm -rf "${bundle_dir}"

  configure_path
}
