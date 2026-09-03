#!/data/data/com.termux/files/usr/bin/bash

yh_web_pause() { printf '\n%sPress any key to return…%s' "$YH_DIM" "$YH_RESET"; yh_read_key >/dev/null || true; }

yh_web_open() {
  local url="$1"
  [[ "$url" =~ ^https?:// ]] || url="https://$url"
  w3m "$url"
}

yh_web_run() {
  local choice url i
  local bookmarks="$YH_DATA_DIR/bookmarks"
  touch "$bookmarks"
  if ! command -v w3m >/dev/null 2>&1; then yh_clear_screen; printf 'w3m is not installed. Run: pkg install w3m\n'; yh_web_pause; return; fi
  while true; do
    yh_clear_screen
    printf '%s%sWEB%s\n' "$YH_BOLD$YH_CYAN" "$YH_APP_NAME — " "$YH_RESET"
    yh_draw_rule "${YH_UI_WIDTH:-72}"
    printf '[1] Open URL\n[2] Open a favorite\n[3] Add favorite\n[4] View favorites\n\n[q] Back\n> '
    IFS= read -rsn1 choice; printf '\n'
    case "$choice" in
      q|$'\e') return ;;
      1) yh_clear_screen; printf 'URL: '; IFS= read -r url; [[ -n "$url" ]] && yh_web_open "$url" ;;
      2)
        mapfile -t YH_WEB_FAVORITES < "$bookmarks"; (( ${#YH_WEB_FAVORITES[@]} )) || { printf 'No favorites.\n'; yh_web_pause; continue; }
        yh_clear_screen; for i in "${!YH_WEB_FAVORITES[@]}"; do printf '[%d] %s\n' "$((i+1))" "${YH_WEB_FAVORITES[$i]}"; done
        printf 'Number: '; IFS= read -r i
        [[ "$i" =~ ^[0-9]+$ && "$i" -ge 1 && "$i" -le "${#YH_WEB_FAVORITES[@]}" ]] && yh_web_open "${YH_WEB_FAVORITES[$((i-1))]}" ;;
      3) yh_clear_screen; printf 'URL to save: '; IFS= read -r url; [[ -n "$url" ]] && { [[ "$url" =~ ^https?:// ]] || url="https://$url"; printf '%s\n' "$url" >> "$bookmarks"; } ;;
      4) yh_clear_screen; nl -ba "$bookmarks"; yh_web_pause ;;
    esac
  done
}
