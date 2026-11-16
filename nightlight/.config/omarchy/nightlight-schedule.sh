#!/usr/bin/env bash
# Sets hyprsunset to an explicit on/off temperature (not a toggle, so a timer
# firing twice in a row is harmless) and refreshes the Quickshell indicator.
set -euo pipefail

ON_TEMP=4000
OFF_TEMP=6500

case "${1:-}" in
  on) TARGET_TEMP=$ON_TEMP ;;
  off) TARGET_TEMP=$OFF_TEMP ;;
  *) echo "usage: $0 on|off" >&2; exit 1 ;;
esac

# At login a Persistent timer can fire before Hyprland's socket is up; wait
# for it instead of failing the unit.
for _ in {1..60}; do
  hyprctl version >/dev/null 2>&1 && break
  sleep 1
done
hyprctl version >/dev/null 2>&1 || { echo "Hyprland not reachable, skipping" >&2; exit 0; }

if ! pgrep -x hyprsunset >/dev/null; then
  setsid uwsm-app -- hyprsunset &
  sleep 1
fi

for _ in {1..10}; do
  hyprctl hyprsunset temperature "$TARGET_TEMP" >/dev/null 2>&1 || true
  current=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+' | head -n1 || true)
  [[ "$current" == "$TARGET_TEMP" ]] && break
  sleep 0.2
done

omarchy-shell -q nightlight refresh 2>/dev/null || true
