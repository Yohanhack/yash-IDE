#!/data/data/com.termux/files/usr/bin/bash

yh_editor_load() {
  YH_EDITOR_LINES=()
  [[ -f "$YH_CURRENT_FILE" ]] && mapfile -t YH_EDITOR_LINES < "$YH_CURRENT_FILE"
  (( ${#YH_EDITOR_LINES[@]} )) || YH_EDITOR_LINES=("")
  YH_EDITOR_ROW=0; YH_EDITOR_COL=0; YH_EDITOR_DIRTY=0
  if [[ "${YH_EDITOR_GOTO_LINE:-}" =~ ^[0-9]+$ ]] && (( YH_EDITOR_GOTO_LINE <= ${#YH_EDITOR_LINES[@]} )); then YH_EDITOR_ROW=$((YH_EDITOR_GOTO_LINE-1)); fi
  unset YH_EDITOR_GOTO_LINE
  YH_EDITOR_UNDO=(); YH_EDITOR_REDO=()
}

yh_editor_snapshot() {
  YH_EDITOR_UNDO+=("$(declare -p YH_EDITOR_LINES)" "row=$YH_EDITOR_ROW" "col=$YH_EDITOR_COL")
  YH_EDITOR_REDO=()
}

yh_editor_undo() {
  local n=$(( ${#YH_EDITOR_UNDO[@]} - 3 ))
  (( n >= 0 )) || return 0
  YH_EDITOR_REDO+=("$(declare -p YH_EDITOR_LINES)" "row=$YH_EDITOR_ROW" "col=$YH_EDITOR_COL")
  eval "${YH_EDITOR_UNDO[$n]}"; eval "${YH_EDITOR_UNDO[$((n+1))]}"; eval "${YH_EDITOR_UNDO[$((n+2))]}"
  unset 'YH_EDITOR_UNDO[n]' 'YH_EDITOR_UNDO[n+1]' 'YH_EDITOR_UNDO[n+2]'
  YH_EDITOR_UNDO=("${YH_EDITOR_UNDO[@]}"); YH_EDITOR_DIRTY=1
}

yh_editor_save() {
  printf '%s\n' "${YH_EDITOR_LINES[@]}" > "$YH_CURRENT_FILE"
  YH_EDITOR_DIRTY=0; YH_EDITOR_MESSAGE="Saved"
}

yh_editor_render() {
  local i line before after display cursor mark=""
  yh_clear_screen
  [[ "$YH_EDITOR_DIRTY" -eq 1 ]] && mark=" *"
  printf '%s%sEDITOR%s  %s%s\n' "$YH_BOLD$YH_CYAN" "$YH_APP_NAME — " "$YH_RESET" "$(yh_path_display "$YH_CURRENT_FILE")" "$mark"
  yh_draw_rule 72
  for i in "${!YH_EDITOR_LINES[@]}"; do
    line="${YH_EDITOR_LINES[$i]}"
    if [[ "$i" -eq "$YH_EDITOR_ROW" ]]; then
      before="${line:0:YH_EDITOR_COL}"; cursor="${line:YH_EDITOR_COL:1}"; after="${line:YH_EDITOR_COL+1}"
      [[ -z "$cursor" ]] && cursor=' '
      display="${before}${YH_YELLOW}[${cursor}]${YH_RESET}${after}"
      printf '%s%4d | %b%s\n' "$YH_GREEN" "$((i+1))" "$display" "$YH_RESET"
    else
      printf '%4d | %s\n' "$((i+1))" "$line"
    fi
  done
  printf '\n'; yh_draw_rule 72
  printf '%sCtrl+S%s Save  %sCtrl+Z%s Undo  %sCtrl+F%s Find  %sCtrl+Q%s Back  %s%s%s\n' "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET" "${YH_EDITOR_MESSAGE:-}" "$YH_RESET"
}

yh_editor_insert() {
  local key="$1" line="${YH_EDITOR_LINES[$YH_EDITOR_ROW]}"
  yh_editor_snapshot
  YH_EDITOR_LINES[$YH_EDITOR_ROW]="${line:0:YH_EDITOR_COL}${key}${line:YH_EDITOR_COL}"
  YH_EDITOR_COL=$((YH_EDITOR_COL + ${#key})); YH_EDITOR_DIRTY=1
}

yh_editor_newline() {
  local line="${YH_EDITOR_LINES[$YH_EDITOR_ROW]}" tail="${line:YH_EDITOR_COL}"
  yh_editor_snapshot; YH_EDITOR_LINES[$YH_EDITOR_ROW]="${line:0:YH_EDITOR_COL}"
  YH_EDITOR_LINES=("${YH_EDITOR_LINES[@]:0:YH_EDITOR_ROW+1}" "$tail" "${YH_EDITOR_LINES[@]:YH_EDITOR_ROW+1}")
  YH_EDITOR_ROW=$((YH_EDITOR_ROW+1)); YH_EDITOR_COL=0; YH_EDITOR_DIRTY=1
}

yh_editor_backspace() {
  local line
  (( YH_EDITOR_COL > 0 || YH_EDITOR_ROW > 0 )) || return 0
  yh_editor_snapshot; line="${YH_EDITOR_LINES[$YH_EDITOR_ROW]}"
  if (( YH_EDITOR_COL > 0 )); then
    YH_EDITOR_LINES[$YH_EDITOR_ROW]="${line:0:YH_EDITOR_COL-1}${line:YH_EDITOR_COL}"; YH_EDITOR_COL=$((YH_EDITOR_COL-1))
  else
    YH_EDITOR_COL=${#YH_EDITOR_LINES[$((YH_EDITOR_ROW-1))]}
    YH_EDITOR_LINES[$((YH_EDITOR_ROW-1))]+="$line"
    YH_EDITOR_LINES=("${YH_EDITOR_LINES[@]:0:YH_EDITOR_ROW}" "${YH_EDITOR_LINES[@]:YH_EDITOR_ROW+1}")
    YH_EDITOR_ROW=$((YH_EDITOR_ROW-1))
  fi
  YH_EDITOR_DIRTY=1
}

yh_editor_find() {
  local query i line
  yh_clear_screen; printf 'Find (vide pour annuler) : '; IFS= read -r query
  [[ -z "$query" ]] && return 0
  for i in "${!YH_EDITOR_LINES[@]}"; do
    line="${YH_EDITOR_LINES[$i]}"
    if [[ "$line" == *"$query"* ]]; then YH_EDITOR_ROW=$i; YH_EDITOR_COL=$(expr index "$line" "$query"); YH_EDITOR_COL=$((YH_EDITOR_COL-1)); YH_EDITOR_MESSAGE="Found: $query"; return 0; fi
  done
  YH_EDITOR_MESSAGE="Not found: $query"
}

yh_editor_run() {
  local key line
  [[ -n "$YH_CURRENT_FILE" ]] || { YH_EDITOR_MESSAGE="Open a file from Explorer first"; return; }
  yh_editor_load
  while true; do
    yh_editor_render; key="$(yh_read_key)" || return
    line="${YH_EDITOR_LINES[$YH_EDITOR_ROW]}"; YH_EDITOR_MESSAGE=""
    case "$key" in
      $'\x11') return ;;  # Ctrl+Q
      $'\x13') yh_editor_save ;;
      $'\x1a') yh_editor_undo ;;
      $'\x06') yh_editor_find ;;
      $'\e[A')
        if (( YH_EDITOR_ROW > 0 )); then YH_EDITOR_ROW=$((YH_EDITOR_ROW-1)); fi
        if (( YH_EDITOR_COL > ${#YH_EDITOR_LINES[$YH_EDITOR_ROW]} )); then YH_EDITOR_COL=${#YH_EDITOR_LINES[$YH_EDITOR_ROW]}; fi ;;
      $'\e[B')
        if (( YH_EDITOR_ROW < ${#YH_EDITOR_LINES[@]}-1 )); then YH_EDITOR_ROW=$((YH_EDITOR_ROW+1)); fi
        if (( YH_EDITOR_COL > ${#YH_EDITOR_LINES[$YH_EDITOR_ROW]} )); then YH_EDITOR_COL=${#YH_EDITOR_LINES[$YH_EDITOR_ROW]}; fi ;;
      $'\e[D') ((YH_EDITOR_COL > 0)) && YH_EDITOR_COL=$((YH_EDITOR_COL-1)) ;;
      $'\e[C') ((YH_EDITOR_COL < ${#line})) && YH_EDITOR_COL=$((YH_EDITOR_COL+1)) ;;
      $'\177'|$'\b') yh_editor_backspace ;;
      ''|$'\r'|$'\n') yh_editor_newline ;;
      *) [[ "$key" =~ ^[[:print:]]+$ ]] && yh_editor_insert "$key" ;;
    esac
  done
}
