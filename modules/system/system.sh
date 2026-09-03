#!/data/data/com.termux/files/usr/bin/bash

yh_system_pause() { printf '\n%sPress any key to return…%s' "$YH_DIM" "$YH_RESET"; yh_read_key >/dev/null || true; }

yh_system_run() {
  local choice
  while true; do
    yh_clear_screen
    printf '%s%sSYSTEM%s\n' "$YH_BOLD$YH_CYAN" "$YH_APP_NAME — " "$YH_RESET"
    yh_draw_rule "${YH_UI_WIDTH:-72}"
    printf '[1] Quick summary\n[2] Processes\n[3] Interactive btop\n\n[q] Back\n> '
    IFS= read -rsn1 choice; printf '\n'
    case "$choice" in
      q|$'\e') return ;;
      1) uname -a; printf '\n'; uptime 2>/dev/null || true; printf '\n'; df -h "$HOME"; yh_system_pause ;;
      2) ps -ef 2>/dev/null || ps; yh_system_pause ;;
      3) if command -v btop >/dev/null 2>&1; then btop; else printf 'btop is not installed. Run: pkg install btop\n'; yh_system_pause; fi ;;
    esac
  done
}
