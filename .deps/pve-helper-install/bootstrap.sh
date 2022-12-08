# install tool specific libs
. "$(lt_dl .deps/${LT_BASEDIR}/lib.main.sh .deps/${LT_BASEDIR}/lib.main.sh)"

# execute main bootstrap
SRC_COMMON_ENV="$(lt_dl .deps/_mix/common.env .deps/_mix/common.env)"
. "${SRC_COMMON_ENV}" || lt_rc_fail "Can't source ${SRC_COMMON_ENV}"

trap_help_opt "${@}" && print_help && exit

SRC_INC_OPTS="$(lt_dl .deps/${LT_BASEDIR}/inc.opts.sh .deps/${LT_BASEDIR}/inc.opts.sh)"
. "${SRC_INC_OPTS}" || trap_fatal $? "Can't source ${SRC_INC_OPTS}"

while ! ${OPTS[confirm]}; do
  read -p "Install PVE helpers [y/N]: " -r
  [[ "${REPLY,}" == y ]] && { OPTS[confirm]=true; continue; }
  [[ "${REPLY,}" == n ]] && exit
  [[ -z "${REPLY}" ]] && exit
  print_stderr "Invalid response!"
done

#
# ACTION
#

log_info "Installing helpers ..."
sleep 1

install_helpers \
&& log_info OK \
|| log_warn "Failed!"
