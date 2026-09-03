#!/data/data/com.termux/files/usr/bin/bash

source "$PROJECT_ROOT/config/config.sh"
source "$PROJECT_ROOT/config/keybindings.sh"
source "$PROJECT_ROOT/config/paths.sh"
source "$PROJECT_ROOT/config/theme.sh"
source "$PROJECT_ROOT/ui/colors.sh"
source "$PROJECT_ROOT/core/state.sh"
source "$PROJECT_ROOT/core/events.sh"
source "$PROJECT_ROOT/core/session.sh"
source "$PROJECT_ROOT/ui/renderer.sh"
source "$PROJECT_ROOT/core/router.sh"
source "$PROJECT_ROOT/utils/filesystem.sh"
source "$PROJECT_ROOT/services/file_service.sh"
source "$PROJECT_ROOT/modules/explorer/explorer.sh"
source "$PROJECT_ROOT/modules/editor/editor.sh"
source "$PROJECT_ROOT/modules/search/search.sh"
source "$PROJECT_ROOT/integrations/ranger.sh"
source "$PROJECT_ROOT/modules/terminal/terminal.sh"
source "$PROJECT_ROOT/modules/git/git.sh"
source "$PROJECT_ROOT/modules/packages/packages.sh"
source "$PROJECT_ROOT/modules/web/web.sh"
source "$PROJECT_ROOT/modules/storage/storage.sh"
source "$PROJECT_ROOT/modules/system/system.sh"

yh_cleanup() {
  printf '\033[?25h\033[0m\n'
}

yh_read_key() {
  local first rest
  IFS= read -rsn1 first || return 1
  if [[ "$first" == $'\e' ]]; then
    IFS= read -rsn2 -t 0.05 rest || true
    printf '%s%s' "$first" "$rest"
  else
    printf '%s' "$first"
  fi
}

yh_main() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    printf '%s must be launched from an interactive terminal.\n' "$YH_APP_NAME" >&2
    return 1
  fi

  trap yh_cleanup EXIT INT TERM
  trap yh_handle_resize WINCH
  yh_session_init
  yh_handle_resize
  printf '\033[?25l'
  while true; do
    yh_render_home
    key="$(yh_read_key)" || break
    yh_handle_key "$key" || break
  done
}
