#!/data/data/com.termux/files/usr/bin/bash
yh_log() { printf '%s %s\n' "$(date '+%F %T')" "$*" >> "${YH_DATA_DIR:-/tmp}/yh-termux.log"; }
