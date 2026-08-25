#!/usr/bin/env bash
# Sets the keyboard backlight to an explicit on/off level (not a toggle, so a
# timer firing twice in a row is harmless).
set -euo pipefail

device=""
for candidate in /sys/class/leds/*kbd_backlight*; do
  if [[ -e $candidate ]]; then
    device="$(basename "$candidate")"
    break
  fi
done

[[ -n $device ]] || { echo "No keyboard backlight device found" >&2; exit 1; }

case "${1:-}" in
  on) brightnessctl -q -d "$device" set 255 ;;
  off) brightnessctl -q -d "$device" set 0 ;;
  *) echo "usage: $0 on|off" >&2; exit 1 ;;
esac
