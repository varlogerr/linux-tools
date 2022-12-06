print_help() {
  text_decore "
    Perform proxmox after installation basic configuration.
   .
    USAGE:
   .  # Generate configuration file mock to stdout or
   .  # CONFFILE. -y option to force override CONFFILE
   .  ${LT_TOOLNAME} [-y|--yes] --conf-gen [CONFFILE]
   .
   .  # Perform configuration with settings from CONFFILE.
   .  # -y        to run without confirmation to proceed
   .  # --reboot  will reboot the OS disregarding the
   .  #           value from CONFFILE. The flag takes
   .  #           affect only with either of:
   .  #           * FIX_GRUB_USB_ISSUE=true
   .  #           * PERFORM_UPGRADE=true
   .  ${LT_TOOLNAME} [-y|--yes] [--reboot] [--] CONFFILE
   .
    Development:
    * LT_BRANCH   Env var to manipulate with branch
  "
}

print_opts_txt() {
  text_decore '
    ###############################
    # PVE post-install tool options
    ###############################
    # Disable enterprice PVE repo
    PVE_DISABLE_ENTERPRISE_REPO=true
    # Add non-subscription repo
    # (not adviced for heavy prod)
    PVE_ENABLE_NOSUBSCRIPTION_REPO=true
    # Remove annoying subscription reminder from web-UI
    PVE_DISABLE_SUBSCRIPTION_NAG=true
    # When some USB ports don'\''t work with enabled IOMMU
    # in BIOS. The solution is based on point 3 from:
    # https://bbs.minisforum.com/threads/the-iommu-issue-boot-and-usb-problems.2180/
    # Applied fix requires reboot
    FIX_GRUB_USB_ISSUE=false
    # Upgrade the system
    PERFORM_UPGRADE=true
    # Cleanup repo cache, tmp, logs.
    PERFORM_CLEANUP=true
    # Works only with either of:
    # * FIX_GRUB_USB_ISSUE=true
    # * PERFORM_UPGRADE=true
    PERFORM_REBOOT=false
  '
}
