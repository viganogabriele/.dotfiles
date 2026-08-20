#!/usr/bin/env bash
# Waybar adapter for the official CodexBar Linux CLI.
# Shows cached values when a provider is temporarily unavailable.

set -u

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/codexbar-waybar-local"
CACHE_FILE="$CACHE_DIR/usage.json"
mkdir -p "$CACHE_DIR"

fetch_usage() {
  local provider="$1" source="$2"
  timeout 35 codexbar usage --provider "$provider" --source "$source" --format json --no-color 2>/dev/null
}

valid_usage() {
  jq -e 'type == "array" and length > 0 and .[0].provider != null and .[0].usage != null and .[0].error == null' >/dev/null 2>&1
}

cache_provider() {
  local provider="$1"
  [ -f "$CACHE_FILE" ] || return 0
  jq -c --arg provider "$provider" '.[$provider] // empty' "$CACHE_FILE" 2>/dev/null
}

claude_raw=$(fetch_usage claude oauth || true)
codex_raw=$(fetch_usage codex cli || true)
claude_fresh=false
codex_fresh=false

if printf '%s' "$claude_raw" | valid_usage; then
  claude="$claude_raw"
  claude_fresh=true
else
  claude=$(cache_provider claude)
fi

if printf '%s' "$codex_raw" | valid_usage; then
  codex="$codex_raw"
  codex_fresh=true
else
  codex=$(cache_provider codex)
fi

if [ -z "${claude:-}" ] && [ -z "${codex:-}" ]; then
  jq -nc '{text:"AI usage unavailable", tooltip:"CodexBar could not read Claude or Codex yet.", class:"ai-warn"}'
  exit 0
fi

# Preserve the last successful reading per provider.  A transient 429 never
# replaces a usable value with an empty/zero reading.
if [ "$claude_fresh" = true ] || [ "$codex_fresh" = true ]; then
  state='{}'
  [ -f "$CACHE_FILE" ] && state=$(cat "$CACHE_FILE" 2>/dev/null || echo '{}')
  [ "$claude_fresh" = true ] && state=$(jq --argjson value "$claude" '.claude = $value' <<<"$state")
  [ "$codex_fresh" = true ] && state=$(jq --argjson value "$codex" '.codex = $value' <<<"$state")
  temp_file=$(mktemp "$CACHE_DIR/usage.XXXXXX")
  printf '%s\n' "$state" > "$temp_file"
  mv "$temp_file" "$CACHE_FILE"
fi

provider_label() {
  local provider="$1" data="$2" freshness="$3"
  jq -r --arg provider "$provider" --arg freshness "$freshness" '
    .[0].usage as $usage |
    def percent($window):
      if $window == null or $window.usedPercent == null then "—"
      else "\($window.usedPercent | round)%" end;
    def gauge($window):
      if $window == null or $window.usedPercent == null then "▱▱▱▱▱▱"
      else ((($window.usedPercent * 6 / 100) + 0.5) | floor) as $raw |
        (if $window.usedPercent > 0 and $raw < 1 then 1 else $raw end) as $filled |
        [range(0; 6) | if . < $filled then "▰" else "▱" end] | join("")
      end;
    def color($window):
      if $window == null or $window.usedPercent == null then "#6c7086"
      elif $window.usedPercent >= 90 then "#f38ba8"
      elif $window.usedPercent >= 75 then "#f9e2af"
      else "#a6e3a1" end;
    ($usage.primary // $usage.secondary) as $display |
    "\($provider) <span foreground=\"\(color($display))\">\(gauge($display))  \(percent($usage.primary)) · \(percent($usage.secondary))</span>" +
    (if $freshness == "false" then "  (cached)" else "" end)
  ' <<<"$data"
}

provider_tooltip() {
  local provider="$1" data="$2" freshness="$3"
  jq -r --arg provider "$provider" --arg freshness "$freshness" '
    .[0].usage as $usage |
    def line($name; $window):
      if $window == null or $window.usedPercent == null then "  \($name): —"
      else "  \($name): \($window.usedPercent | round)%  · resets \($window.resetDescription // "—")" end;
    "\($provider)" +
    (if $freshness == "false" then "  (ultimo dato valido)" else "" end) + "\n" +
    line("5h"; $usage.primary) + "\n" +
    line("7d"; $usage.secondary)
  ' <<<"$data"
}

text_parts=()
tooltip_parts=("CodexBar usage")
values=()

if [ -n "${claude:-}" ]; then
  text_parts+=("$(provider_label Claude "$claude" "$claude_fresh")")
  tooltip_parts+=("$(provider_tooltip Claude "$claude" "$claude_fresh")")
  values+=("$(jq -r '.[0].usage.primary.usedPercent // empty, .[0].usage.secondary.usedPercent // empty' <<<"$claude")")
fi
if [ -n "${codex:-}" ]; then
  text_parts+=("$(provider_label Codex "$codex" "$codex_fresh")")
  tooltip_parts+=("$(provider_tooltip Codex "$codex" "$codex_fresh")")
  values+=("$(jq -r '.[0].usage.primary.usedPercent // empty, .[0].usage.secondary.usedPercent // empty' <<<"$codex")")
fi

highest=0
while IFS= read -r value; do
  if [[ "$value" =~ ^[0-9]+([.][0-9]+)?$ ]] && awk "BEGIN { exit !($value > $highest) }"; then
    highest="$value"
  fi
done < <(printf '%s\n' "${values[@]}")

class=codexbar-usage

text=""
for part in "${text_parts[@]}"; do
  [ -n "$text" ] && text+="   |   "
  text+="$part"
done
tooltip=$(IFS=$'\n\n'; printf '%s' "${tooltip_parts[*]}")
jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" '{text:$text, tooltip:$tooltip, class:$class}'
