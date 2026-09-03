#!/data/data/com.termux/files/usr/bin/bash

# Ranger fournit la navigation. --choosefile écrit le fichier sélectionné
# afin que YH-Termux puisse le transmettre à son propre éditeur.
yh_ranger_run() {
  local chosen_file
  if ! command -v ranger >/dev/null 2>&1; then
    yh_clear_screen
    printf '%sRanger is not installed.%s\n\nInstall it in Termux with:\n  pkg install ranger\n\nPress any key to use the built-in explorer.' "$YH_YELLOW" "$YH_RESET"
    yh_read_key >/dev/null || true
    yh_explorer_run
    return
  fi

  chosen_file="$(mktemp "${TMPDIR:-/data/data/com.termux/files/usr/tmp}/yh-ranger.XXXXXX")"
  rm -f "$chosen_file"
  ranger --choosefile="$chosen_file" "${YH_CURRENT_DIRECTORY:-$YH_WORKSPACE}"

  if [[ -f "$chosen_file" ]]; then
    YH_CURRENT_FILE="$(<"$chosen_file")"
    rm -f "$chosen_file"
    if [[ -f "$YH_CURRENT_FILE" ]]; then
      YH_CURRENT_DIRECTORY="$(dirname "$YH_CURRENT_FILE")"
      YH_SELECTED_INDEX=1
      YH_CURRENT_MODULE="Editor"
      yh_editor_run
    fi
  fi
}
