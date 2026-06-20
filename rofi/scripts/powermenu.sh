#!/usr/bin/env bash

confirm() {
  echo -e "No\nYes" | rofi -dmenu \
    -i \
    -p "$1" \
    -theme ~/.config/rofi/config.rasi
}

chosen=$(printf "  Lock\n󰍃  Logout\n󰤄  Suspend\n󰒲  Reboot\n󰐥  Shutdown" |
  rofi -dmenu \
    -i \
    -p "Power" \
    -theme ~/.config/rofi/config.rasi)

case "$chosen" in
"  Lock")
  hyprlock
  ;;

"󰍃  Logout")
  [[ "$(confirm "Logout?")" == "Yes" ]] && hyprctl dispatch exit
  ;;

"󰤄  Suspend")
  [[ "$(confirm "Suspend?")" == "Yes" ]] && systemctl suspend
  ;;

"󰒲  Reboot")
  [[ "$(confirm "Reboot?")" == "Yes" ]] && systemctl reboot
  ;;

"󰐥  Shutdown")
  [[ "$(confirm "Shutdown?")" == "Yes" ]] && systemctl poweroff
  ;;
esac
