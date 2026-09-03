#!/data/data/com.termux/files/usr/bin/bash

yh_open_selected_module() {
  case "$YH_CURRENT_MODULE" in
    Explorer) yh_explorer_run ;;
    Editor) yh_editor_run ;;
    Search) yh_search_run ;;
    *) yh_render_placeholder; yh_read_key >/dev/null || true ;;
  esac
}

yh_handle_key() {
  local key="$1"
  case "$key" in
    q|Q) return 1 ;;
    j|$'\e[B') yh_select_next ;;
    k|$'\e[A') yh_select_previous ;;
    ''|$'\r'|$'\n') yh_open_selected_module ;;
  esac
  return 0
}
