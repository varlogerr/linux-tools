debian_upgrade() {
  (
    set -x
    apt-get update &>/dev/null \
    && apt-get -y dist-upgrade &>/dev/null
  )
}

debian_cleanup() {
  (
    set -x
    apt-get -y autoremove &>/dev/null
    apt-get -y clean &>/dev/null
    apt-get -y autoclean &>/dev/null
    find /tmp/ /var/tmp/ -mindepth 1 -maxdepth 1 -exec rm -rf {} \; &>/dev/null
    find /var/log/ -type f -exec truncate -s 0 {} \; &>/dev/null
  )
}
