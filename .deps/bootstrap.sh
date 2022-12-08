# install general libs
declare -a libs=(
  debian
  pve
  shlib
  sys
); for l in "${libs[@]}"; do
  . "$(lt_dl ".deps/lib.${l}.sh" ".deps/lib.${l}.sh")"
done

# # apply shlib overrides
# LOG_TOOLNAME="${LT_TOOLNAME}"

# execute tool bootstrap
SRC_BOOTSTRAP="$(lt_dl ".deps/${LT_BOOTSTRAP}" ".deps/${LT_BOOTSTRAP}")"
. "${SRC_BOOTSTRAP}" || trap_fatal $? "Can't source ${SRC_BOOTSTRAP}"
