#!/bin/bash
# Tracks the real keyboard layout (US/IT) across ANY physical keyboard and:
#  - writes the current short layout to a state file for the waybar module
#  - signals waybar to refresh it
#  - shows a brief OSD notification on switch (Alt+Alt)
#
# Hyprland also reports layout events for virtual/pseudo "keyboard" devices
# (software IME, media/power hotkey controllers, bluetooth AVRCP, etc). Those
# are not real typing keyboards and must be ignored, otherwise they fire
# spurious events on window focus changes.
EXCLUDE_RE='virtual|hotkeys|power-button|video-bus|avrcp|consumer-control'

STATE_FILE="$HOME/.cache/kb-layout-state"
SIGNAL=11

update_state() {
  local layout="$1"
  local short
  case "$layout" in
    *Italian*) short="it" ;;
    *English*) short="us" ;;
    *) short="$layout" ;;
  esac
  echo "$short" > "$STATE_FILE"
  pkill -RTMIN+"$SIGNAL" waybar 2>/dev/null
  echo "$short"
}

# Seed the state file from the first real keyboard we find, so waybar has
# something to show before the first switch happens.
initial_layout=$(hyprctl devices -j | jq -r --arg re "$EXCLUDE_RE" \
  '.keyboards[] | select(.name | test($re) | not) | .active_keymap' | head -n1)
[ -n "$initial_layout" ] && update_state "$initial_layout" > /dev/null

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
  case "$line" in
    activelayout*)
      payload="${line#*>>}"
      device="${payload%%,*}"
      layout="${payload#*,}"
      echo "$device" | grep -qE "$EXCLUDE_RE" && continue
      short=$(update_state "$layout")
      notify-send -a "keyboard" -u low -t 500 \
        -h string:x-canonical-private-synchronous:kb-layout \
        "Tastiera: ${short^^}"
      ;;
  esac
done
