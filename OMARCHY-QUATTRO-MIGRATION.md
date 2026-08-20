# Omarchy 3.8.5 → 4.0 "Quattro" migration notes

Written just before running `omarchy-upgrade-to-quattro` (2026-08-20), from
Omarchy 3.8.5 / Hyprland 0.56.2, channel `stable`.

The upgrade is **one-way**: the script itself prints "You cannot downgrade from
Quattro." Restore points that exist:

- Pre-upgrade Btrfs snapshot: the upgrade script calls `omarchy-snapshot create`
  automatically before it touches anything (`create_pre_upgrade_snapshot`).
- Git tag `pre-omarchy-quattro` in this repo = last pre-Quattro state of all
  configs, plus `pkglist_*.txt` captured from the 3.8.5 system.
- The script backs up whatever it replaces to
  `<file>.omarchy-upgrade-to-quattro.<timestamp>.bak` (ignored by `.gitignore`,
  so those live on disk only, not in git).

## What Quattro changes

- The whole desktop shell becomes **Quickshell** (one process). It replaces and
  removes: Waybar, Walker, Mako, SwayOSD, hyprlock, hypridle, swaybg,
  polkit-gnome.
- Hyprland config moves from `.conf` to **Lua**. Quattro installs
  `~/.config/hypr/{hyprland,bindings,monitors,input,looknfeel,autostart}.lua`
  and loads `require("default.hypr.omarchy")` from the packaged defaults.
- Omarchy stops being a git checkout in `~/.local/share/omarchy` and becomes
  package-backed under `/usr/share/omarchy`.

## Impact on this stow repo

The upgrade renames these `~/.config` entries to `.bak`. They are **symlinks**
into this repo, so `mv` moves only the link — the contents here are untouched,
but the stow packages become inert:

| stow package | what happens |
| --- | --- |
| `waybar` | symlink retired; Waybar is gone in Quattro |
| `walker` | symlink retired; replaced by the Quickshell launcher |
| `swayosd` | symlink retired; replaced by the Quickshell OSD |
| `hypr` | symlink kept; `.conf` files are left in place but **Quattro ignores them** |
| `ghostty`, `uwsm`, `zsh`, `xcompose`, `battery`, `personal` | unaffected |

`uwsm/env` (not tracked here, all Omarchy defaults) is retired; custom lines
would be migrated to `~/.config/uwsm/env.d/99-omarchy-upgrade-env`. Our real
customizations live in `uwsm/default` (tracked), which the script preserves
because its hash does not match a shipped default.

## Customizations that must be re-created in Lua

Source of truth to port from: `hypr/.config/hypr/bindings.conf` in this repo
(the file survives the upgrade, it just stops being read).

### 1. Per-monitor workspaces (the important one)

Provided by the hyprpm plugin **split-monitor-workspaces** (zjeffer). It gives
each monitor its own independent set of 10 workspaces (monitor 1 → 1-10,
monitor 2 → 11-20), so `SUPER+1..0` always means "this monitor's Nth workspace".

**Status: disabled on 2026-08-20, before the upgrade.** It is still installed
and built under hyprpm (`hyprpm list` shows it), just not loaded: the config
block and its binds are gone from `bindings.conf` and `exec-once = hyprpm
reload -n` is commented out in `autostart.conf`.

Why it was disabled — the failure mode to solve before re-enabling: the plugin
assigns workspace ranges in the order it encounters monitors, so unplugging the
external screen re-enumerated the laptop panel onto a fresh empty 21-30 range
while the open windows stayed behind on an orphaned 11-20. Result: a blank
laptop screen with no obvious way back into the session. Setting
`monitor_priority = eDP-1, HDMI-A-1, DP-2` pinned which monitor owns which
range and fixed the reassignment, but windows already sitting on a range that
lost its monitor were still stranded. `hyprctl dispatch split-grabroguewindows`
pulls such windows back onto the active monitor and is the manual escape hatch.

So the Lua port needs an answer for monitor hotplug, not just a translation of
the binds. Worth checking whether Quattro's own multi-monitor handling, or the
plugin's maintained Lua package, behaves better here before reintroducing it.

Legacy `.conf` form currently in use:

```
plugin {
    split-monitor-workspaces {
        count = 10
        keep_focused = 0
        enable_notifications = 0
        enable_persistent_workspaces = 1
        enable_wrapping = 1
        link_monitors = 0
    }
}
```

with dispatchers `split-workspace`, `split-movetoworkspacesilent`,
`split-cycleworkspaces`, `split-changemonitor` bound over Omarchy's defaults
(which had to be `unbind`-ed first).

Lua equivalents documented by the plugin: config goes under
`hl.config({ plugin = { split_monitor_workspaces = { ... } } })` (underscores),
and functions under `hl.plugin.split_monitor_workspaces` — `.workspace(n)`,
`.move_to_workspace_silent(n)`, `.cycle_workspaces(...)`, `.change_monitor(...)`.
Verify on the upgraded system before trusting this.

Caveat: the C++/hyprpm variant of the plugin is deprecated upstream and
supports Hyprland ≤ 0.56.x. If Quattro moves past that, switch to the plugin's
native Lua package (requires Hyprland ≥ 0.55), which is the maintained path.

### 2. Monitor navigation binds

- `SUPER + code:34 / code:35` → focus (keyboard + cursor) previous/next monitor
- `SUPER SHIFT + code:34 / code:35` → move active window to previous/next monitor

Quattro ships `CTRL+ALT+TAB` / `CTRL+ALT+SHIFT+TAB` for monitor focus, so check
whether the custom binds are still worth keeping.

### 3. Everything else in `bindings.conf`

App launchers, web apps, and the `SUPER ALT` arrow media binds. In Lua these
become `o.bind("SUPER + RETURN", "Terminal", "<command>")`; unbinding a default
first is `hl.unbind("SUPER + ...")`.

### 4. Waybar tweaks (now obsolete)

`waybar/.config/waybar/` had a workspace module showing the correct 1-10 number
per monitor (mapping ids 11-20 and 21-30 back to 1-0) and an active-workspace
underline in `style.css`. Quattro's bar is configured through
`omarchy bar` / `~/.config/omarchy/shell.json` instead — the same "which
workspace is active on which screen" readout has to be rebuilt there.

## After the upgrade

1. Reboot (the real Lua cutover happens on reboot, not in the live session).
2. `hyprpm update && hyprpm reload` (alias `hyprfix`) — Hyprland version
   changed, so the plugin must be rebuilt against the new ABI.
3. Check `hyprctl workspaces` shows split ranges (1-10 on one monitor, 11-20 on
   the other) to confirm the plugin is live.
4. Re-run `stow` for the packages that are still relevant, and drop/retire the
   ones Quattro made obsolete.
