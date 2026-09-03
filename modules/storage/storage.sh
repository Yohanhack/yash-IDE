#!/data/data/com.termux/files/usr/bin/bash

yh_storage_pause() { printf '\n%sPress any key to return…%s' "$YH_DIM" "$YH_RESET"; yh_read_key >/dev/null || true; }

yh_storage_run() {
  local choice
  while true; do
    yh_clear_screen
    printf '%s%sSTORAGE%s  %s\n' "$YH_BOLD$YH_CYAN" "$YH_APP_NAME — " "$YH_RESET" "$(yh_path_display "$YH_WORKSPACE")"
    yh_draw_rule "${YH_UI_WIDTH:-72}"
    printf '[1] Disk summary\n[2] Workspace size\n[3] Largest workspace entries\n[4] Interactive ncdu\n\n[q] Back\n> '
    IFS= read -rsn1 choice; printf '\n'
    case "$choice" in
      q|$'\e') return ;;
      1) df -h "$YH_WORKSPACE"; yh_storage_pause ;;
      2) du -sh "$YH_WORKSPACE" 2>/dev/null; yh_storage_pause ;;
      3) du -sh "$YH_WORKSPACE"/* 2>/dev/null | sort -h | tail -20; yh_storage_pause ;;
      4)
        if command -v ncdu >/dev/null 2>&1; then ncdu "$YH_WORKSPACE"; else printf 'ncdu is not installed. Run: pkg install ncdu\n'; yh_storage_pause; fi ;;
    esac
  done
}
