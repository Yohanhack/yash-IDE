#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for file in "$root/yh" "$root/install.sh" "$root"/{core,ui,config}/*.sh; do
  bash -n "$file"
done
printf 'Syntaxe Bash valide.\n'
