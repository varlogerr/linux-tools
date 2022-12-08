#!/usr/bin/env bash

LT_BASEDIR=pve-post-install
LT_BOOTSTRAP="${LT_BASEDIR}/bootstrap.sh"

# {BOILERPLATE}
  #
  # BOILERPLATE CONFIGURATION
  #
  # The boilerplate is not supposed to be modified.
  # Overrides can be done with pre-set env vars.
  #
  # Must overrides:
  #   * LT_BASEDIR
  #   * LT_BOOTSTRAP
  # More available overrides:
  #   * LT_BRANCH
  #   * LT_DEPSDIR
  #
  LT_TOOLNAME="$(basename -- "${0}")"
  LT_BINDIR="$(dirname "$(realpath -- "${BASH_SOURCE[0]}")")"

  LT_BRANCH="${LT_BRANCH:-master}"
  LT_DEPSDIR="${LT_DEPSDIR:-$(mktemp -d --suffix -linux-tools 2>/dev/null)}" \
    || { echo "Can't create temp directory" >&2; exit; }
  LT_BASEDIR="${LT_BASEDIR}"
  LT_BOOTSTRAP="${LT_BOOTSTRAP}"

  LT_HOMEURL=https://github.com/varlogerr/linux-tools/raw/${LT_BRANCH}

  #
  # BASIC FUNCTIONS
  #
  # ```
  # cd SOME_DIR || lt_rc_fail "Can't cd to SOME_DIR"
  # ```
  lt_rc_fail() {
    local rc=${?}
    [[ "${rc}" -gt 0 ]] || return
    declare -F trap_fatal &> /dev/null \
    && trap_fatal ${rc} "${1}" \
    || { echo "${1}" >&2; exit ${rc}; }
  }

  # ```
  # lt_dl REQUIRED_TOOL DEST_FILENAME
  #
  # # Custom home url download example:
  # TL_HOMEURL=https://github.com/ANOTHER_REPO \
  #   lt_dl REQUIRED_TOOL DEST_FILENAME
  #
  # # Custom destination location download example:
  # LT_DEPSDIR=/opt/tools/sometool.sh \
  #   lt_dl REQUIRED_TOOL DEST_FILENAME
  # ```
  # Outputs downloaded file path
  lt_dl() {
    local req="${1}"
    local dest_path="${LT_DEPSDIR}/${2}"
    local req_url="${LT_HOMEURL}/${req}"
    local git_rootdir; git_rootdir="$(realpath -- "${LT_BINDIR}/..")"
    local dest_dir; dest_dir="$(dirname -- "${dest_path}")"

    [[ -f "${dest_path}" ]] && { echo "${dest_path}"; return; }
    mkdir -p "${dest_dir}" || lt_rc_fail "Can't create directory: ${dest_path}"
    test -d "${git_rootdir}/.git" \
    && /bin/cp -f "${git_rootdir}/${req}" "${dest_path}" &>/dev/null \
    || wget -q -L -O "${dest_path}" "${req_url}" &>/dev/null \
    || curl -f -s -L -o "${dest_path}" "${req_url}" &>/dev/null \
    || lt_rc_fail "Can't download '${req}' to '${dest_path}'"

    echo "${dest_path}"
  }

  # execute main bootstrap
  SRC_BOOTSTRAP="$(lt_dl .deps/bootstrap.sh .deps/bootstrap.sh)"
  . "${SRC_BOOTSTRAP}" || lt_rc_fail "Can't source ${SRC_BOOTSTRAP}"
# {/BOILERPLATE}
