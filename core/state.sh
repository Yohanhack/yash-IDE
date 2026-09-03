#!/data/data/com.termux/files/usr/bin/bash

YH_MODULES=("Explorer" "Editor" "Search" "Web" "Packages" "Git" "Storage" "Terminal" "Settings")
YH_SELECTED_INDEX=0
YH_CURRENT_MODULE="${YH_MODULES[0]}"
YH_WORKSPACE="${YH_WORKSPACE:-$PWD}"
YH_CURRENT_DIRECTORY="$YH_WORKSPACE"
YH_CURRENT_FILE=""

yh_select_next() {
  YH_SELECTED_INDEX=$(( (YH_SELECTED_INDEX + 1) % ${#YH_MODULES[@]} ))
  YH_CURRENT_MODULE="${YH_MODULES[$YH_SELECTED_INDEX]}"
}

yh_select_previous() {
  YH_SELECTED_INDEX=$(( (YH_SELECTED_INDEX - 1 + ${#YH_MODULES[@]}) % ${#YH_MODULES[@]} ))
  YH_CURRENT_MODULE="${YH_MODULES[$YH_SELECTED_INDEX]}"
}
