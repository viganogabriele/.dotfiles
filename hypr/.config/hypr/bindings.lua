-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Restore my pre-Quattro app bindings over the defaults they collided with.
hl.unbind("SUPER + SHIFT + A") -- was: ChatGPT
o.bind("SUPER + SHIFT + A", "Chromium", { launch = "chromium" })

hl.unbind("SUPER + SHIFT + C") -- was: Calendar
o.bind("SUPER + SHIFT + C", "Editor", { launch = "code" })

hl.unbind("SUPER + SHIFT + P") -- was: Google Photos
o.bind("SUPER + SHIFT + P", "Passwords", { launch = "1password" })

hl.unbind("SUPER + SHIFT + D") -- was: Docker
o.bind("SUPER + SHIFT + D", "T3 Code (Fixed)", 'omarchy-launch-or-focus t3code "t3code-nightly --password-store=gnome-libsecret"')

hl.unbind("SUPER + SHIFT + O") -- was: Obsidian
o.bind("SUPER + SHIFT + O", "Btop", 'omarchy-launch-or-focus Btop "omarchy-launch-tui btop"')

-- WhatsApp instead of Gemini/Signal on SUPER+SHIFT+G; SUPER+SHIFT+ALT+G keeps the default WhatsApp binding too.
hl.unbind("SUPER + SHIFT + G") -- was: Signal
o.bind("SUPER + SHIFT + G", "WhatsApp", 'omarchy-launch-or-focus-webapp WhatsApp "https://web.whatsapp.com/"')

-- Telegram: free key, no default to unbind.
o.bind("SUPER + SHIFT + T", "Telegram", "omarchy-launch-or-focus Telegram")

-- Claude / ChatGPT web: free keys, no default to unbind.
-- Always opens a new browser window (not focus-if-open).
o.bind("SUPER + U", "Claude", 'omarchy-launch-webapp "https://claude.ai/new"')
o.bind("SUPER + I", "ChatGPT", 'omarchy-launch-webapp "https://chatgpt.com/"')

-- Media control using Super + Alt + Arrows.
-- These were actually bound by default to window-grouping (move window to
-- group on left/right) -- unbind those first.
hl.unbind("SUPER + ALT + RIGHT") -- was: Move window to group on right
hl.unbind("SUPER + ALT + LEFT") -- was: Move window to group on left
o.bind("SUPER + ALT + RIGHT", "Next track", "playerctl next")
o.bind("SUPER + ALT + LEFT", "Previous track", "playerctl previous")

-- Move every window on the active workspace to workspace N (SUPER+SHIFT+N
-- only moves the focused window). Free keys, no default to unbind.
-- Key "0" targets workspace 10, matching SUPER+0's convention.
local function move_workspace_windows(target)
  local ws = hl.get_active_workspace()
  for _, w in ipairs(hl.get_workspace_windows(ws)) do
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(target), window = w, follow = false }))
  end
  hl.dispatch(hl.dsp.focus({ workspace = tostring(target) }))
end

for i = 0, 9 do
  local workspace = (i == 0) and 10 or i
  o.bind("SUPER + CTRL + SHIFT + " .. i, "Move workspace to " .. workspace, function()
    move_workspace_windows(workspace)
  end)
end

-- BEGIN OmaPilot managed hotkeys
-- Added at the user request from OmaPilot settings. Edit these bindings freely.
hl.unbind("SUPER + A")
o.bind("SUPER + A", "Talk to OmaPilot",
  "omarchy-shell -q io.github.spencerbull.omapilot voiceToggle")
hl.unbind("SUPER + ALT + X")
o.bind("SUPER + ALT + X", "Cancel OmaPilot voice mode",
  "omarchy-shell -q io.github.spencerbull.omapilot voiceCancel")
hl.unbind("SUPER + ALT + N")
o.bind("SUPER + ALT + N", "New OmaPilot chat",
  "omarchy-shell -q io.github.spencerbull.omapilot newChat")
hl.unbind("SUPER + ALT + H")
o.bind("SUPER + ALT + H", "Continue OmaPilot chat in Herdr",
  "omarchy-shell -q io.github.spencerbull.omapilot continueInHerdr")
-- END OmaPilot managed hotkeys
