#!/data/data/com.termux/files/usr/bin/bash

yh_terminal_run() {
  if ! command -v tmux >/dev/null 2>&1; then
    yh_clear_screen
    printf '%stmux is not installed.%s\nRun: pkg install tmux\n' "$YH_YELLOW" "$YH_RESET"
    yh_read_key >/dev/null || true
    return
  fi
  yh_clear_screen
  printf '%sOpening persistent YH terminal…%s\n' "$YH_CYAN" "$YH_RESET"
  sleep 0.3
  tmux new-session -A -s yh-main
}
