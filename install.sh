#!/data/data/com.termux/files/usr/bin/bash
# Installe une commande yh dans le préfixe Termux.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX_DIR="${PREFIX:-/data/data/com.termux/files/usr}"
BIN_DIR="$PREFIX_DIR/bin"

if [[ ! -d "$BIN_DIR" ]]; then
  printf 'Termux semble absent : %s n existe pas.\n' "$BIN_DIR" >&2
  exit 1
fi

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/yh-termux" "${XDG_DATA_HOME:-$HOME/.local/share}/yh-termux"
ln -sfn "$ROOT/yh" "$BIN_DIR/yh"
chmod +x "$ROOT/yh"
printf 'YH-Termux V0.1 est installe. Lancez : yh\n'
