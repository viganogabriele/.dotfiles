#!/usr/bin/env bash

battery=/sys/class/power_supply/BAT0
status=$(<"$battery/status")
capacity=$(<"$battery/capacity")

if [[ -r "$battery/power_now" ]]; then
  power=$(<"$battery/power_now")
  watts=$(awk -v p="$power" 'BEGIN { printf "%.0f", p / 1000000 }')
elif [[ -r "$battery/current_now" && -r "$battery/voltage_now" ]]; then
  current=$(<"$battery/current_now")
  voltage=$(<"$battery/voltage_now")
  watts=$(awk -v c="$current" -v v="$voltage" 'BEGIN { printf "%.0f", c * v / 1000000000000 }')
else
  watts=0
fi

if [[ "$status" == Charging ]]; then
  case "$capacity" in
    0|1[0-9]) icon='󰢜' ;;
    2[0-9]|3[0-9]) icon='󰂆' ;;
    4[0-9]|5[0-9]) icon='󰂇' ;;
    6[0-9]|7[0-9]) icon='󰂈' ;;
    8[0-9]) icon='󰢝' ;;
    *) icon='󰂅' ;;
  esac
else
  case "$capacity" in
    0|1[0-9]) icon='󰁺' ;;
    2[0-9]) icon='󰁻' ;;
    3[0-9]) icon='󰁼' ;;
    4[0-9]) icon='󰁽' ;;
    5[0-9]) icon='󰁾' ;;
    6[0-9]) icon='󰁿' ;;
    7[0-9]) icon='󰂀' ;;
    8[0-9]) icon='󰂁' ;;
    9[0-9]) icon='󰂂' ;;
    *) icon='󰁹' ;;
  esac
fi

if (( capacity <= 20 )); then battery_color='#f38ba8'
elif (( capacity <= 50 )); then battery_color='#f9e2af'
else battery_color='#a6e3a1'
fi

if [[ "$status" == Charging ]]; then
  if (( watts < 15 )); then watt_color='#f38ba8'
  elif (( watts < 30 )); then watt_color='#f9e2af'
  else watt_color='#a6e3a1'
  fi
  text="<span foreground='$watt_color'>$watts W↑</span> <span foreground='$battery_color'>$capacity% $icon</span>"
else
  text="<span foreground='$battery_color'>$capacity% $icon</span>"
fi

printf '{"text":"%s","tooltip":"Battery: %s%%\\nPower: %s W\\nStatus: %s"}\n' "$text" "$capacity" "$watts" "$status"
