#!/data/data/com.termux/files/usr/bin/bash

yh_explorer_render() {
  local i path name suffix marker
  yh_clear_screen
  printf '%s%sEXPLORER%s  %s\n' "$YH_BOLD$YH_CYAN" "$YH_APP_NAME — " "$YH_RESET" "$(yh_path_display "$YH_EXPLORER_DIR")"
  yh_draw_rule 64
  printf '%s..%s\n' "$YH_DIM" "$YH_RESET"
  for i in "${!YH_EXPLORER_ENTRIES[@]}"; do
    path="${YH_EXPLORER_ENTRIES[$i]}"; name="$(basename "$path")"; suffix=""
    [[ -d "$path" ]] && suffix="/"
    marker=' '
    [[ "$i" -eq "$YH_EXPLORER_INDEX" ]] && marker="${YH_GREEN}>${YH_RESET}"
    printf '%b %s%s\n' "$marker" "$name" "$suffix"
  done
  [[ "${#YH_EXPLORER_ENTRIES[@]}" -eq 0 ]] && printf '%s  (dossier vide)%s\n' "$YH_DIM" "$YH_RESET"
  printf '\n'; yh_draw_rule 64
  printf '%s↑/k ↓/j%s Navigate  %sEnter%s Open  %sh%s Parent  %sn%s File  %sd%s Folder  %sq/Esc%s Back\n' "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET"
}

yh_explorer_refresh() {
  mapfile -t YH_EXPLORER_ENTRIES < <(yh_file_entries "$YH_EXPLORER_DIR")
  if (( YH_EXPLORER_INDEX >= ${#YH_EXPLORER_ENTRIES[@]} )); then
    YH_EXPLORER_INDEX=0
  fi
}

yh_explorer_create() {
  local type="$1" target
  yh_clear_screen
  printf 'Nom du %s (vide pour annuler) : ' "$type"
  IFS= read -r target
  [[ -z "$target" || "$target" == *'/'* ]] && return
  if [[ "$type" == "fichier" ]]; then : > "$YH_EXPLORER_DIR/$target"; else mkdir "$YH_EXPLORER_DIR/$target"; fi
  yh_explorer_refresh
}

yh_explorer_run() {
  local key selected
  YH_EXPLORER_DIR="${YH_CURRENT_DIRECTORY:-$YH_WORKSPACE}"
  YH_EXPLORER_INDEX=0
  yh_explorer_refresh
  while true; do
    yh_explorer_render
    key="$(yh_read_key)" || return
    case "$key" in
      q|$'\e') return ;;
      j|$'\e[B') YH_EXPLORER_INDEX=$(( (YH_EXPLORER_INDEX + 1) % (${#YH_EXPLORER_ENTRIES[@]} || 1) )) ;;
      k|$'\e[A') YH_EXPLORER_INDEX=$(( (YH_EXPLORER_INDEX - 1 + ${#YH_EXPLORER_ENTRIES[@]}) % (${#YH_EXPLORER_ENTRIES[@]} || 1) )) ;;
      h|$'\e[D') YH_EXPLORER_DIR="$(dirname "$YH_EXPLORER_DIR")"; YH_EXPLORER_INDEX=0; yh_explorer_refresh ;;
      n) yh_explorer_create fichier ;;
      d) yh_explorer_create dossier ;;
      ''|$'\r'|$'\n')
        (( ${#YH_EXPLORER_ENTRIES[@]} == 0 )) && continue
        selected="${YH_EXPLORER_ENTRIES[$YH_EXPLORER_INDEX]}"
        if [[ -d "$selected" ]]; then
          YH_EXPLORER_DIR="$selected"; YH_EXPLORER_INDEX=0; yh_explorer_refresh
        else
          YH_CURRENT_FILE="$selected"; YH_CURRENT_DIRECTORY="$YH_EXPLORER_DIR"; YH_SELECTED_INDEX=1; YH_CURRENT_MODULE="Editor"
          return
        fi
        ;;
    esac
  done
}
