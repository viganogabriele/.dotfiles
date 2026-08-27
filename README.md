# 🐧 My Omarchy Dotfiles

Personal configuration for **Omarchy 4 "Quattro"** (Arch Linux + Hyprland),
synced between two machines — a laptop (`gabrielelaptop`) and a desktop —
via `git` + `GNU Stow`. The goal is that both machines stay an exact copy of
each other except for the handful of things that genuinely have to differ
(monitor scale, battery-only services).

## 🚀 Quick start (new/reset machine)

```bash
git clone git@github.com:viganogabriele/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` is **idempotent** — safe to re-run any time, on either machine,
as many times as you want. It:

1. Pulls the latest commits.
2. Updates the system and installs `base-devel`, `git`, `stow`, `zsh`, `yay`.
3. Installs every package in `pkglist_native.txt` / `pkglist_aur.txt`.
4. **Prunes**: lists packages installed on this machine but no longer in
   those files, and asks before removing them with `pacman -Rns` (see
   [Removing obsolete packages](#-removing-obsolete-packages)).
5. Handles kernel headers / boot image regen, `pnpm`, Oh My Zsh.
6. Symlinks every dotfiles module with `stow` (see
   [How stow packages are discovered](#-how-stow-packages-are-discovered)).
7. Enables the laptop-only systemd timers only where the hardware exists
   (see [Laptop vs. desktop](#-laptop-vs-desktop)).
8. Installs VS Code extensions, system-level files (udev rules, helper
   scripts under `/usr/local/bin`), refreshes the font cache, sets `zsh` as
   the default shell.

Reboot afterwards to make sure everything (Hyprland Lua config, kernel,
udev rules) is picked up.

## 🔄 Keeping both machines in sync

**Push from the machine you just changed something on:**

```bash
dotsave   # alias for ~/.dotfiles/sync.sh, defined in .zshrc
```

`sync.sh` pulls first (rebase), scans for secrets with **Gitleaks**, calls
`refresh_lists.sh` to snapshot the current package/extension lists, then
commits and pushes — but only if there's actually something to commit.

**Pull on the other machine:**

```bash
dotup   # alias for ~/.dotfiles/install.sh
```

Since `install.sh` starts with a `git pull` and every step is `--needed` /
idempotent, this is the *only* command you need on the receiving end —
there's no separate "quick sync" script to keep in sync with the real one.

## 📁 How stow packages are discovered

`install.sh` does **not** hardcode a list of folder names. It scans every
top-level directory in the repo and stows it, except:

- **`RETIRED_FOLDERS`** (`waybar`, `walker`, `swayosd`) — superseded by the
  Omarchy 4 "Quattro" upgrade (its own Quickshell-based bar/launcher/OSD).
  Kept in the repo for reference only, never linked. See
  `OMARCHY-QUATTRO-MIGRATION.md`.
- **`NON_STOW_FOLDERS`** (`system`) — not `$HOME` configs (udev rules,
  `/usr/local/bin` scripts), installed by a dedicated step instead.

This means **adding a new stow package is just "make a new top-level
folder shaped like `$HOME`"** — nothing else to register anywhere. This is
also why the previous version of this script silently failed to link two
whole packages (`kbd-backlight`, `nightlight`) on a fresh machine: they
existed in the repo but nobody had added them to a hand-maintained array.

`nvim/` is stowed with `--no-folding` because it contains an absolute
symlink of its own (see below) — GNU Stow can't safely fold a package
directory into one symlink when one of the files inside is itself a
symlink.

## 💻 Laptop vs. desktop

Two things in this repo are genuinely machine-specific:

- **Monitor scale** (`hypr/.config/hypr/monitors.lua`): reads its
  `gdk_scale` / `monitor_scale` from `hypr/.config/hypr/monitors.local.lua`,
  which is **gitignored** — never committed, never synced. Copy
  `monitors.local.lua.example` to `monitors.local.lua` on each machine once
  and set the values that make sense for *that* machine's screen. Shared
  binds/settings in `monitors.lua` itself stay identical everywhere.
- **`battery/` and `kbd-backlight/`**: always linked on both machines (so
  the files themselves keep syncing normally), but their systemd timers are
  only *enabled* where the hardware exists — `install.sh` checks for
  `/sys/class/power_supply/BAT*` and `/sys/class/leds/*kbd_backlight*` and
  enables/disables accordingly. `nightlight/` has no hardware dependency
  and is always enabled.

Everything else — binds, aliases, plugins, shell config, editor config — is
byte-identical between the two machines by construction (it's the same
symlinked file).

## 🔌 Omarchy plugins

Two different things live under `~/.config/omarchy/plugins/`:

- **Plugins I wrote** (`io.github.viganogabriele.*`, `gabriele.workspaces`) —
  tracked as regular stow packages/submodules (`agents/`, `kdeconnect/`,
  `notes/`, `omarchy-workspaces/`), same as everything else in this repo.
- **Marketplace plugins from other authors** (OmaPilot, Vitals, Gitarchy,
  etc.) — these aren't config, they're separately-installed third-party
  code, so they're tracked the same way as pacman packages: `refresh_lists.sh`
  snapshots the installed ones (id + git URL) into
  `pkglist_omarchy_plugins.txt`, and `install.sh` runs
  `omarchy plugin add <url> --enable --yes` for any missing from that list.
  Already-installed plugins are never touched (no re-clone, no state reset).

  **Trust note**: `omarchy plugin add` normally warns that plugins run as
  unsandboxed code and asks for confirmation before cloning. `install.sh`
  skips that prompt (`--yes`) on the assumption that every URL in
  `pkglist_omarchy_plugins.txt` was already reviewed once, by hand, on the
  machine that installed it originally. Don't add a plugin URL to this file
  (or run `omarchy plugin add` non-interactively) without having actually
  looked at what it does first.

**Apps that aren't packages or plugins**: Omarchy web-app shortcuts (Discord,
ChatGPT-as-app, etc.) are just `.desktop` files, invisible to both the
pacman prune step and the plugin list. Manage those directly with
`omarchy-webapp-remove` / `omarchy-webapp-install`.

## 🗑️ Removing obsolete packages

When a machine has drifted (e.g. the desktop still had Omarchy 3 packages —
`waybar`, `walker`, `mako`, `hyprlock`, `hypridle`, `polkit-gnome` — after
being upgraded to Quattro), `install.sh` step 4 shows you exactly what's
installed but no longer tracked, with each package's description, and asks
once before running `pacman -Rns`. It never removes anything silently.

**Read the list before confirming** — a package can legitimately be
installed on only one machine (a GPU driver, a wifi firmware package) simply
because the pkglists reflect whichever machine last ran `refresh_lists.sh`.
If in doubt, say no and leave it; nothing forces you to prune every run.

## 🔐 Secrets

- **Gitleaks** runs on every `sync.sh`/`dotsave` and aborts the push if it
  finds anything. Known false positives are allow-listed in
  `.gitleaksignore`.
- **`gh/`** only tracks `~/.config/gh/config.yml` (CLI preferences).
  `~/.config/gh/hosts.yml` (the OAuth token) is deliberately **never**
  copied into this repo.
- `*.bak` / `*.bak.*` files (conflict backups `install.sh` creates, and the
  ones the Quattro upgrade itself created) are gitignored.

## 📦 What's tracked and why

Only things that are actually hand-customized are stowed — plain
Omarchy-default files that happen to exist on disk (e.g. the default
`~/.config/fontconfig/fonts.conf`, or `~/.config/mimeapps.list`, which is
regenerated automatically as apps are installed/uninstalled and legitimately
differs per machine) are deliberately **not** in here. If you change one of
those away from the default, add it then — see `AGENTS.md` for the rule.

| Folder | What |
| --- | --- |
| `hypr/` | Hyprland (Lua config, binds, shaders, monitor layout) |
| `agents/`, `claude-skills/`, `kdeconnect/`, `notes/`, `omarchy-workspaces/` | Omarchy Quickshell plugins (submodules where the plugin has its own repo) |
| `zsh/` | Zsh, Oh My Zsh, custom aliases/init (`zsh/.zsh/`) |
| `nvim/` | Neovim (LazyVim-based) |
| `git/` | Git identity, GPG/SSH commit signing, allowed signers — no secrets |
| `gh/` | GitHub CLI preferences (not the auth token) |
| `tmux/`, `starship/`, `mise/` | Terminal multiplexer, prompt, tool version pins |
| `ghostty/`, `vscode/` | Terminal emulator, VS Code settings/keybindings |
| `autostart/` | Which login-autostart apps are enabled/disabled |
| `environment/` | `environment.d` overrides (currently: ssh-agent) |
| `battery/`, `kbd-backlight/`, `nightlight/` | Omarchy systemd timers — see [Laptop vs. desktop](#-laptop-vs-desktop) |
| `xcompose/`, `uwsm/` | `.XCompose`, uwsm environment overrides |
| `personal/` | Own scripts (VPN autostart, etc.) |
| `system/` | Not stowed — udev rule + helper script installed straight to `/etc` and `/usr/local/bin` |
| `waybar/`, `walker/`, `swayosd/` | Retired by Quattro, kept for reference only |

## 🛠️ Scripts

| Script | Purpose |
| --- | --- |
| `install.sh` | Bootstrap **and** ongoing sync target: pulls, installs/prunes packages, links everything with stow, enables the right systemd timers. Safe to re-run anytime. |
| `sync.sh` | Pulls, checks secrets, refreshes the package lists, commits and pushes. Aliased to `dotsave`. |
| `refresh_lists.sh` | Snapshots `pkglist_native.txt`, `pkglist_aur.txt`, `vscode_extensions.txt` from the current system. Called by `sync.sh`, but safe to run standalone. |

## 🤖 Working on this repo with an AI assistant

See `AGENTS.md` (and `CLAUDE.md`, which points to it) for the standing rule
about keeping this repo in sync with real changes on disk.
