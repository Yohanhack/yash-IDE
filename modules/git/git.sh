#!/data/data/com.termux/files/usr/bin/bash

yh_git_root() {
  git -C "$YH_WORKSPACE" rev-parse --show-toplevel 2>/dev/null
}

yh_git_pause() {
  printf '\n%sPress any key to return…%s' "$YH_DIM" "$YH_RESET"
  yh_read_key >/dev/null || true
}

yh_git_output() {
  yh_clear_screen
  printf '%sGIT — %s%s\n' "$YH_BOLD$YH_CYAN" "$1" "$YH_RESET"
  yh_draw_rule "${YH_UI_WIDTH:-72}"
  shift
  "$@"
  yh_git_pause
}

yh_git_commit() {
  local message
  yh_clear_screen
  git -C "$YH_GIT_ROOT" status --short
  printf '\nCommit message (empty cancels): '
  IFS= read -r message
  [[ -z "$message" ]] && return 0
  git -C "$YH_GIT_ROOT" add -A
  if git -C "$YH_GIT_ROOT" commit -m "$message"; then
    printf '%sCommit created.%s\n' "$YH_GREEN" "$YH_RESET"
  else
    printf '%sCommit failed; nothing was changed after Git rejected it.%s\n' "$YH_YELLOW" "$YH_RESET"
  fi
  yh_git_pause
}

yh_git_branch() {
  local branch choice
  yh_clear_screen
  printf '%sBRANCHES%s\n\n' "$YH_BOLD$YH_CYAN" "$YH_RESET"
  git -C "$YH_GIT_ROOT" branch --all
  printf '\nType an existing branch to switch, or a new name to create (empty cancels): '
  IFS= read -r branch
  [[ -z "$branch" ]] && return 0
  if git -C "$YH_GIT_ROOT" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$YH_GIT_ROOT" switch "$branch"
  else
    printf 'Create branch %s? [y/N] ' "$branch"; IFS= read -rsn1 choice; printf '\n'
    [[ "$choice" =~ ^[yY]$ ]] && git -C "$YH_GIT_ROOT" switch -c "$branch"
  fi
  yh_git_pause
}

yh_git_run() {
  local choice
  if ! command -v git >/dev/null 2>&1; then
    yh_clear_screen; printf 'Git is not installed. Run: pkg install git\n'; yh_git_pause; return
  fi
  YH_GIT_ROOT="$(yh_git_root)"
  if [[ -z "$YH_GIT_ROOT" ]]; then
    yh_clear_screen; printf 'The current workspace is not a Git repository.\n'; yh_git_pause; return
  fi
  while true; do
    yh_clear_screen
    printf '%s%sGIT%s  %s\n' "$YH_BOLD$YH_CYAN" "$YH_APP_NAME — " "$YH_RESET" "$(yh_path_display "$YH_GIT_ROOT")"
    yh_draw_rule "${YH_UI_WIDTH:-72}"
    printf '[1] Status\n[2] Diff\n[3] Commit all changes\n[4] Branches / switch\n[5] Pull\n[6] Push\n[7] Open lazygit\n\n[q] Back\n'
    printf '> '; IFS= read -rsn1 choice; printf '\n'
    case "$choice" in
      q|$'\e') return ;;
      1) yh_git_output Status git -C "$YH_GIT_ROOT" status --short --branch ;;
      2) yh_git_output Diff git -C "$YH_GIT_ROOT" diff --stat; yh_git_output 'Diff details' git -C "$YH_GIT_ROOT" diff ;;
      3) yh_git_commit ;;
      4) yh_git_branch ;;
      5) yh_git_output Pull git -C "$YH_GIT_ROOT" pull --ff-only ;;
      6) yh_git_output Push git -C "$YH_GIT_ROOT" push ;;
      7)
        if command -v lazygit >/dev/null 2>&1; then lazygit -p "$YH_GIT_ROOT"; else yh_clear_screen; printf 'lazygit is not installed. Run: pkg install lazygit\n'; yh_git_pause; fi ;;
    esac
  done
}
