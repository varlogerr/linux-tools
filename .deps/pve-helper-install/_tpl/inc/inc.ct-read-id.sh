while [[ -z "${OPTS[id]}" ]]; do
  text_decore "
    Press enter with blank input to list available LXC containers.
  " | print_stderr
  read -p "Choose container ID: " -r

  ct_check_id "${REPLY}" \
  && { OPTS[id]="${REPLY}"; continue; }

  [[ -n "${REPLY}" ]] && print_stderr "Invalid ID! Containers list:"
  ct_bullet_id_name | print_stderr
done
