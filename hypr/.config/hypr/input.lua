-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    -- US (international, for accented letters via ' and ` dead keys) + IT.
    -- Switch between them with Caps Lock (grp:caps_toggle).
    -- NOTE: previously "grp:alts_toggle" (Left Alt + Right Alt), but that
    -- option grabs the Right Alt key so it can no longer act as AltGr on
    -- the IT layout, breaking AltGr+o (@) and other AltGr symbols.
    -- Then tried "grp:alt_shift_toggle" (Left Alt + Left Shift), but that
    -- combo gets hit accidentally during normal typing/shortcuts, causing
    -- the layout to switch on its own.
    kb_layout = "us,it",
    kb_variant = "intl,",
    kb_options = "grp:caps_toggle",

    -- Change speed of keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 600,

    -- Start with numlock on by default.
    numlock_by_default = true,

    touchpad = {
      -- Use natural (inverse) scrolling.
      natural_scroll = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.4,

      -- Omarchy's default turns this on, which makes right/middle click
      -- depend on how many fingers are down for ANY click, instead of
      -- clicking in the physical bottom-right/bottom-middle button area.
      -- Turn it off to get a real "right-click button" in the corner back.
      clickfinger_behavior = false,
    },
  },
})

-- Logitech M510 mouse: lower its sensitivity.
hl.device({
  name = "logitech-m510",
  sensitivity = -0.6,
})

-- App-specific touchpad scroll speeds.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })
