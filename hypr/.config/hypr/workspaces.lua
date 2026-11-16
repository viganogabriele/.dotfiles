-- Workspaces 1-10 live on the laptop screen (eDP-1) only, so SUPER+N never
-- jumps to the external monitor. The external one gets its own workspace
-- (11+, picked by Hyprland) and is reached with the cursor; move windows
-- there by dragging or with SUPER+SHIFT+code:34/35.
-- Persistent: the bar widget expects 1-5 to exist, and Hyprland would
-- otherwise destroy empty unfocused workspaces like 6-10.
for workspace = 1, 10 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = "eDP-1",
    persistent = true,
    default = (workspace == 1),
  })
end
