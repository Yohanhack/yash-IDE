#!/data/data/com.termux/files/usr/bin/bash

yh_has_command() { command -v "$1" >/dev/null 2>&1; }

yh_dependency_report() {
  local tool
  for tool in bash tmux git rg fd fzf yazi lazygit btop ncdu w3m; do
    yh_has_command "$tool" && printf '✓ %s\n' "$tool" || printf '✗ %s\n' "$tool"
  done
}
