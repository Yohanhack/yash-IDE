#!/data/data/com.termux/files/usr/bin/bash

yh_clear_screen() { printf '\033[2J\033[H'; }

yh_draw_rule() { printf '%*s\n' "${1:-60}" '' | tr ' ' '─'; }

yh_render_home() {
  local index module marker
  yh_clear_screen
  printf '%s%s  %s%s\n' "$YH_BOLD$YH_CYAN" "$YH_APP_NAME" "$YH_DIM" "$YH_WORKSPACE$YH_RESET"
  yh_draw_rule 64
  printf '%sMODULES%s\n\n' "$YH_BOLD" "$YH_RESET"

  for index in "${!YH_MODULES[@]}"; do
    module="${YH_MODULES[$index]}"
    if [[ "$index" -eq "$YH_SELECTED_INDEX" ]]; then
      marker="${YH_GREEN}>${YH_RESET}"
      printf '  %b %s%s%s\n' "$marker" "$YH_BOLD" "$module" "$YH_RESET"
    else
      printf '    %s\n' "$module"
    fi
  done

  printf '\n'; yh_draw_rule 64
  printf '%s↑/k ↓/j%s Navigate   %sEnter%s Open   %sq%s Quit\n' "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET"
  printf '%sCtrl+P%s Quick search   %sCtrl+T%s Terminal (coming soon)\n' "$YH_DIM" "$YH_RESET" "$YH_DIM" "$YH_RESET"
}

yh_render_placeholder() {
  yh_clear_screen
  printf '%s%s%s\n' "$YH_BOLD$YH_CYAN" "$YH_CURRENT_MODULE" "$YH_RESET"
  yh_draw_rule 64
  printf '\nThis module is planned for a future version.\n'
  printf 'The V0.1 core is ready: menu, keyboard navigation and routing.\n\n'
  printf '%sPress any key to return to the dashboard.%s' "$YH_DIM" "$YH_RESET"
}
