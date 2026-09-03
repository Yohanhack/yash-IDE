#!/data/data/com.termux/files/usr/bin/bash

yh_file_entries() {
  local directory="$1" entry
  local -a directories=() files=()
  shopt -s nullglob dotglob
  for entry in "$directory"/*; do
    [[ "$(basename "$entry")" == '.' || "$(basename "$entry")" == '..' ]] && continue
    if [[ -d "$entry" ]]; then directories+=("$entry"); else files+=("$entry"); fi
  done
  shopt -u nullglob dotglob
  (( ${#directories[@]} + ${#files[@]} > 0 )) || return 0
  printf '%s\n' "${directories[@]}" "${files[@]}" | LC_ALL=C sort
}
