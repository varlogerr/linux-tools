declare -A OPTS=(
  [dest_prefix]="${LT_DIR_PREFIX_USER_TOOLS}/pve-helper"
  [dest]="${HOME}/${LT_DIR_PREFIX_USER_TOOLS}/pve-helper"
  [confirm]=false
)

endopts=false; while :; do
  [[ -n "${1+x}" ]] || break
  ${endopts} && arg='*' || arg="${1}"

  case "${arg}" in
    --) endopts=true ;;
    -y|--yes) OPTS[confirm]=true ;;
  esac

  shift
done
