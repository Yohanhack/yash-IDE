#!/data/data/com.termux/files/usr/bin/bash

yh_search_run() {
  local query key i
  yh_clear_screen; printf '%sSEARCH%s\n\nSearch files or content: ' "$YH_BOLD$YH_CYAN" "$YH_RESET"
  IFS= read -r query; [[ -z "$query" ]] && return 0
  mapfile -t YH_SEARCH_RESULTS < <(grep -RIl --exclude-dir=.git -- "$query" "$YH_WORKSPACE" 2>/dev/null | head -40)
  if (( ${#YH_SEARCH_RESULTS[@]} == 0 )); then yh_clear_screen; printf 'No result for: %s\nPress a key.' "$query"; yh_read_key >/dev/null; return; fi
  YH_SEARCH_INDEX=0
  while true; do
    yh_clear_screen; printf '%sSEARCH%s  %s\n' "$YH_BOLD$YH_CYAN" "$YH_RESET" "$query"; yh_draw_rule 72
    for i in "${!YH_SEARCH_RESULTS[@]}"; do
      [[ "$i" -eq "$YH_SEARCH_INDEX" ]] && printf '%s> %s%s\n' "$YH_GREEN" "${YH_SEARCH_RESULTS[$i]#$YH_WORKSPACE/}" "$YH_RESET" || printf '  %s\n' "${YH_SEARCH_RESULTS[$i]#$YH_WORKSPACE/}"
    done
    printf '\n%sEnter%s Open  %sEsc%s Back\n' "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET"
    key="$(yh_read_key)" || return
    case "$key" in
      q|$'\e') return ;;
      j|$'\e[B') YH_SEARCH_INDEX=$(( (YH_SEARCH_INDEX+1) % ${#YH_SEARCH_RESULTS[@]} )) ;;
      k|$'\e[A') YH_SEARCH_INDEX=$(( (YH_SEARCH_INDEX-1+${#YH_SEARCH_RESULTS[@]}) % ${#YH_SEARCH_RESULTS[@]} )) ;;
      ''|$'\r'|$'\n') YH_CURRENT_FILE="${YH_SEARCH_RESULTS[$YH_SEARCH_INDEX]}"; YH_SELECTED_INDEX=1; YH_CURRENT_MODULE="Editor"; return ;;
    esac
  done
}
