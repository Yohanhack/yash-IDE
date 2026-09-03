#!/data/data/com.termux/files/usr/bin/bash
# Installe une commande yh dans le préfixe Termux.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX_DIR="${PREFIX:-/data/data/com.termux/files/usr}"
BIN_DIR="$PREFIX_DIR/bin"
LOG_FILE="$ROOT/install.log"
DEPENDENCIES=(ranger tmux git ripgrep fd fzf lazygit btop ncdu w3m golang)

if [[ ! -d "$BIN_DIR" ]]; then
  printf 'Termux semble absent : %s n existe pas.\n' "$BIN_DIR" >&2
  exit 1
fi

if ! command -v pkg >/dev/null 2>&1; then
  printf 'pkg est introuvable : executez ce script depuis Termux.\n' >&2
  exit 1
fi

printf 'YH-Termux — verification des dependances\n' | tee "$LOG_FILE"
if ! pkg update -y >> "$LOG_FILE" 2>&1; then
  printf 'Attention : pkg update a echoue. Tentative d installation tout de meme.\n' | tee -a "$LOG_FILE"
fi

failed=()
for package in "${DEPENDENCIES[@]}"; do
  command_name="$package"
  [[ "$package" == "ripgrep" ]] && command_name="rg"
  if command -v "$command_name" >/dev/null 2>&1; then
    printf '  ✓ %-10s deja installe\n' "$package" | tee -a "$LOG_FILE"
  elif pkg install -y "$package" >> "$LOG_FILE" 2>&1; then
    printf '  ✓ %-10s installe\n' "$package" | tee -a "$LOG_FILE"
  else
    printf '  ✗ %-10s echec (voir install.log)\n' "$package" | tee -a "$LOG_FILE"
    failed+=("$package")
  fi
done

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/yh-termux" "${XDG_DATA_HOME:-$HOME/.local/share}/yh-termux"
mkdir -p "$ROOT/bin"
if command -v go >/dev/null 2>&1; then
  if go mod download >> "$LOG_FILE" 2>&1 && go build -o "$ROOT/bin/yh-tui" ./cmd/yh >> "$LOG_FILE" 2>&1; then
    chmod +x "$ROOT/bin/yh-tui"
    printf '  ✓ interface graphique TUI Go construite\n' | tee -a "$LOG_FILE"
  else
    printf '  ✗ interface TUI Go non construite ; interface Bash conservee (voir install.log)\n' | tee -a "$LOG_FILE"
  fi
fi
ln -sfn "$ROOT/yh" "$BIN_DIR/yh"
chmod +x "$ROOT/yh" "$ROOT/install.sh"
if (( ${#failed[@]} )); then
  printf 'YH-Termux est installe, avec des dependances manquantes : %s\n' "${failed[*]}"
else
  printf 'YH-Termux et toutes les dependances sont installes.\n'
fi
printf 'Lancez : yh\n'
