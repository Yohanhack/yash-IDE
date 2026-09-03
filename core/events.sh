#!/data/data/com.termux/files/usr/bin/bash
yh_handle_resize() {
  YH_UI_WIDTH=$(( $(tput cols 2>/dev/null || printf '80') - 2 ))
  (( YH_UI_WIDTH < 40 )) && YH_UI_WIDTH=40
  YH_RESIZED=1
}

yh_transition() {
  local label="$1" frame
  for frame in '·' '••' '•••'; do
    printf '\r%s%s%s %s' "$YH_CYAN" "$frame" "$YH_RESET" "$label"
    sleep 0.06
  done
  printf '\r%*s\r' "$YH_UI_WIDTH" ''
}
