#!/data/data/com.termux/files/usr/bin/bash

yh_pkg_pause() { printf '\n%sPress any key to return…%s' "$YH_DIM" "$YH_RESET"; yh_read_key >/dev/null || true; }

yh_pkg_name() {
  local action="$1" name
  yh_clear_screen; printf '%s package name (empty cancels): ' "$action"; IFS= read -r name
  [[ "$name" =~ ^[a-zA-Z0-9@+._-]+$ ]] || return 0
  printf '\n'; pkg "$action" -y "$name"; yh_pkg_pause
}

yh_packages_run() {
  local choice query confirm
  if ! command -v pkg >/dev/null 2>&1; then yh_clear_screen; printf 'This module must run in Termux.\n'; yh_pkg_pause; return; fi
  while true; do
    yh_clear_screen
    printf '%s%sPACKAGES%s\n' "$YH_BOLD$YH_CYAN" "$YH_APP_NAME — " "$YH_RESET"
    yh_draw_rule "${YH_UI_WIDTH:-72}"
    printf '[1] Update package lists\n[2] Upgrade installed packages\n[3] Search\n[4] Install\n[5] Remove\n[6] Installed packages\n\n[q] Back\n> '
    IFS= read -rsn1 choice; printf '\n'
    case "$choice" in
      q|$'\e') return ;;
      1) pkg update -y; yh_pkg_pause ;;
      2) pkg upgrade -y; yh_pkg_pause ;;
      3) yh_clear_screen; printf 'Search query: '; IFS= read -r query; [[ -n "$query" ]] && pkg search "$query"; yh_pkg_pause ;;
      4) yh_pkg_name install ;;
      5)
        yh_clear_screen; printf 'Package to remove: '; IFS= read -r query
        [[ "$query" =~ ^[a-zA-Z0-9@+._-]+$ ]] || continue
        printf 'Remove %s? [y/N] ' "$query"; IFS= read -rsn1 confirm; printf '\n'
        [[ "$confirm" =~ ^[yY]$ ]] && { pkg uninstall -y "$query"; yh_pkg_pause; } ;;
      6) pkg list-installed; yh_pkg_pause ;;
    esac
  done
}
