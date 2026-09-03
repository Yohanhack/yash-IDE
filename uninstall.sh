#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
target="${PREFIX:-/data/data/com.termux/files/usr}/bin/yh"
[[ -L "$target" ]] && rm "$target"
printf 'Commande yh supprimée. Les données utilisateur sont conservées.\n'
