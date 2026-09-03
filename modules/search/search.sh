#!/data/data/com.termux/files/usr/bin/bash

yh_search_run() {
  local query key i mode result path line
  yh_clear_screen; printf '%sSEARCH%s\n\n[1] File name  [2] Content\n> ' "$YH_BOLD$YH_CYAN" "$YH_RESET"
  IFS= read -rsn1 mode; printf '\nSearch: '; IFS= read -r query; [[ -z "$query" ]] && return 0
  if [[ "$mode" == 1 ]]; then
    if command -v fd >/dev/null 2>&1; then
      mapfile -t YH_SEARCH_RESULTS < <(fd --type f --hidden --exclude .git --glob "*$query*" "$YH_WORKSPACE" 2>/dev/null | head -80)
    else
      mapfile -t YH_SEARCH_RESULTS < <(find "$YH_WORKSPACE" -type f -iname "*$query*" -not -path '*/.git/*' 2>/dev/null | head -80)
    fi
  elif command -v rg >/dev/null 2>&1; then
    mapfile -t YH_SEARCH_RESULTS < <(rg --line-number --no-heading --color=never --fixed-strings -- "$query" "$YH_WORKSPACE" 2>/dev/null | head -80)
  else
    mapfile -t YH_SEARCH_RESULTS < <(grep -RIn --exclude-dir=.git -- "$query" "$YH_WORKSPACE" 2>/dev/null | head -80)
  fi
  if (( ${#YH_SEARCH_RESULTS[@]} > 0 )) && command -v fzf >/dev/null 2>&1; then
    result="$(printf '%s\n' "${YH_SEARCH_RESULTS[@]}" | fzf --prompt='YH search> ' --height=80%)" || return 0
    if [[ "$mode" == 1 ]]; then YH_CURRENT_FILE="$result"; else path="${result%%:*}"; line="${result#*:}"; YH_CURRENT_FILE="$path"; YH_EDITOR_GOTO_LINE="${line%%:*}"; fi
    YH_SELECTED_INDEX=1; YH_CURRENT_MODULE="Editor"; return
  fi
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
      ''|$'\r'|$'\n')
        result="${YH_SEARCH_RESULTS[$YH_SEARCH_INDEX]}"
        if [[ "$mode" == 1 ]]; then YH_CURRENT_FILE="$result"; else path="${result%%:*}"; line="${result#*:}"; YH_CURRENT_FILE="$path"; YH_EDITOR_GOTO_LINE="${line%%:*}"; fi
        YH_SELECTED_INDEX=1; YH_CURRENT_MODULE="Editor"; return ;;
    esac
  done
}
