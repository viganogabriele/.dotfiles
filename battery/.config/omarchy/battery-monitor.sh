#!/usr/bin/env bash

# Notify once at each threshold while the battery is discharging.
set -euo pipefail

battery=/sys/class/power_supply/BAT0
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
state_file="$state_dir/battery-notification-level"

[[ -r "$battery/capacity" && -r "$battery/status" ]] || exit 0

capacity=$(<"$battery/capacity")
status=$(<"$battery/status")
mkdir -p "$state_dir"

if [[ "$status" != Discharging ]]; then
  rm -f "$state_file"
  exit 0
fi

last_level=0
[[ -r "$state_file" ]] && last_level=$(<"$state_file")

if (( capacity <= 5 && last_level < 5 )); then
  notify-send -u critical -i battery-caution -t 10000 "󰂎 Batteria critica" "Solo ${capacity}%: collega subito il caricatore."
  printf '5\n' > "$state_file"
elif (( capacity <= 10 && last_level < 10 )); then
  notify-send -u critical -i battery-caution -t 10000 "󱐋 Batteria quasi scarica" "Batteria al ${capacity}%: collega il caricatore."
  printf '10\n' > "$state_file"
elif (( capacity <= 20 && last_level < 20 )); then
  notify-send -u normal -i battery-low -t 10000 "󰁺 Batteria bassa" "Batteria al ${capacity}%: valuta di collegare il caricatore."
  printf '20\n' > "$state_file"
fi
