# Instructions for AI coding agents working in this repo

This is a **GNU Stow dotfiles repo** synced between two machines (a laptop,
`gabrielelaptop`, and a desktop) via git. Read `README.md` first for the
overall shape; this file is the standing behavioral rule for any agent
(Claude, Codex, etc.) editing files here or editing files elsewhere on the
system that this repo is supposed to track.

## The core rule: if it's modified, it belongs here

If you (the agent) change a config file under `$HOME` that corresponds to,
or should correspond to, something this repo tracks, **update the copy in
this repo, not just the live file** — and vice versa: if you're asked to
change something in this repo, the change is only real once it's `stow`-ed
back to the live path. Concretely:

1. Check whether the live file (e.g. `~/.config/foo/bar.conf`) is a
   symlink into `~/.dotfiles/...`. If it is, just edit the file — either
   path resolves to the same inode, so editing one edits both. Nothing
   further to do; `git status` in the repo will show the diff.
2. If it's a **real file, not a symlink**, and you just created or
   meaningfully customized it (not a vanilla default some package
   installer dropped there — see below), move it into a stow package here
   (new or existing) and re-run `stow <package>` so the live path becomes a
   symlink. Don't leave a real file on disk that this repo doesn't know
   about if it's the kind of thing the user edits by hand.
3. After making changes here, remind the user (or run it yourself if asked
   to) that `dotsave` (`sync.sh`) is what actually pushes it, and
   `./install.sh` on the other machine is what pulls and re-applies it.
   Editing files in this repo does not, by itself, sync anything.

## What NOT to add

Not everything that exists under `$HOME` is worth tracking. Before adding a
new stow package, ask: **is this something the user actually changed from
its default, or is it just something the OS/Omarchy/an app generated on
install and never touched?** Skip the latter. Concrete examples already
excluded on purpose, so you don't reintroduce them:

- `~/.config/fontconfig/fonts.conf` — this is Omarchy's stock font config,
  unmodified.
- `~/.config/mimeapps.list` — auto-regenerated as apps are installed;
  legitimately differs per machine depending on what's installed there.
- `~/.config/gh/hosts.yml` — contains the GitHub CLI OAuth token. **Never**
  copy this into the repo, `gh/` only tracks `config.yml`.
- Any file containing an API key, password, token, or private key. Gitleaks
  runs on every `sync.sh`, but don't rely on it as the only check — think
  before adding.
- App-generated caches/state under `~/.cache`, `~/.local/share/<app>`,
  Electron `Local Storage`, etc.

If genuinely unsure whether something is a real customization, ask the user
rather than guessing either way.

## How stow packages work here

`install.sh` auto-discovers stow packages: **any top-level directory in
this repo is treated as one**, except the folders listed in
`RETIRED_FOLDERS` (superseded by an Omarchy upgrade, kept for reference)
and `NON_STOW_FOLDERS` (`system/` — not `$HOME` paths, installed by a
separate step). There is no array of package names to remember to update —
adding a folder shaped like `$HOME` (e.g. `foo/.config/foo/config`) is
enough for `install.sh` to pick it up on the next run. If you add a folder
that should be excluded from stow (system-level files, or something
deliberately retired), add it to the relevant array in `install.sh` instead
of leaving it to be auto-stowed by accident.

If a package needs individual per-file symlinks instead of one whole-folder
symlink (e.g. because it contains its own relative or absolute symlink
whose target depth would break if the parent got folded — see `nvim/` and
its `.stow-local-ignore`), add it to `NO_FOLD_FOLDERS` in `install.sh`.

## Machine-specific values

Two machines share this repo but are not identical hardware. The pattern
for anything that must legitimately differ (monitor scale is the current
example) is a **gitignored `*.local.*` override file**, read at runtime
with a safe fallback, sitting next to the shared tracked file — see
`hypr/.config/hypr/monitors.lua` / `monitors.local.lua.example`. Prefer this
pattern over hardcoding a hostname check into a shared, tracked file: a
hostname branch in a tracked file means every future host needs its own
`elseif`, while a local override file needs nothing changed in the shared
file ever again.

For anything hardware-presence-based rather than preference-based (does
this machine have a battery? a keyboard backlight?), detect it directly in
`install.sh` (e.g. `/sys/class/power_supply/BAT*`) rather than a hostname
check — it's correct on a third machine without any edits.

## Secrets discipline

Never commit: API keys/tokens, `gh/hosts.yml`, SSH/GPG private keys,
`.env` files with real values, anything Gitleaks would flag. `git/`'s
`allowed_signers` and `config` are fine (public key material and identity
only). When in doubt, grep the file for anything that looks like a secret
before adding it to a stow package, and check `.gitleaksignore` for
already-known false positives before adding a new suppression.
