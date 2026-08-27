-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Per-machine values (scale, layout) live in monitors.local.lua, which is
-- gitignored (see monitors.local.lua.example): the laptop's HiDPI panel and
-- the desktop's external monitor want different scales, and this repo is
-- shared verbatim between both via stow, so the value can't be hardcoded
-- here without one machine clobbering the other on every sync.
local ok, host = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/monitors.local.lua")
if not ok or type(host) ~= "table" then
  host = {}
end

local omarchy_gdk_scale = host.gdk_scale or 1
local omarchy_monitor_scale = host.monitor_scale or 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
