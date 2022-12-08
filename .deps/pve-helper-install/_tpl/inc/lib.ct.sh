# list containers in format `ID,STATUS,NAME`
#   101,running,test-container
ct_csv() {
  local list; list="$(
    set -o pipefail
    pct list 2>/dev/null | tail -n +2 \
    | text_decore | sed 's/\s\+/,/g'
  )" || trap_fatal $? "Can't get LXC containers list"

  [[ -n "${list}" ]] || trap_fatal 1 "No LXC containers found"

  printf -- '%s\n' "${list}"
}

# list container ids
ct_list_id() {
  ct_csv | sed -e 's/^\([^,]\+\).*$/\1/'
}

# list container in format `ID (NAME)`
#   101 (test-container)
ct_list_id_name() {
  ct_csv | sed -e 's/^\([^,]\+\),[^,]\+,\(.*\)$/\1 (\2)/'
}

# list container in format `* ID (NAME)`
#   * 101 (test-container)
ct_bullet_id_name() {
  ct_list_id_name | sed 's/^/* /'
}

# get container NAME by ID
#   ct_name_by_id ID # => NAME
ct_get_id_name_by_id() {
  ct_list_id_name | grep "^${1} "
}

# check if container ID is valid
#   ct_check_id ID
ct_check_id() {
  grep -qFx -f <(ct_list_id) <<< "${1}"
}

# # MOCK
# ct_csv() {
#   text_decore "
#     101,running,test-container-1
#     102,running,test-container-2
#     103,running,test-container-3
#     104,running,test-container-4
#     510,running,test-container-5
#     521,running,test-container-6
#     522,running,test-container-7
#     523,running,test-container-8
#     601,running,test-container-9
#     602,running,test-container-10
#     603,running,test-container-11
#     604,running,test-container-12
#     605,running,test-container-13
#   "
# }
