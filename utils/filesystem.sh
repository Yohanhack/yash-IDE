#!/data/data/com.termux/files/usr/bin/bash

yh_path_display() {
  local path="$1"
  printf '%s' "${path/#$HOME/\~}"
}

yh_is_safe_workspace_path() {
  [[ -n "$1" && -e "$1" ]]
}
