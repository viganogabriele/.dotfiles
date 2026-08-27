# Claude Code instructions for this repo

Full rules live in **`AGENTS.md`** — read it before making changes here.
It's not Claude-specific on purpose, so other tools (Codex, etc.) follow the
same rules; this file just points at it and adds anything Claude-specific.

Short version of the one rule that matters most: **if a config under
`$HOME` gets modified and it's a real customization (not an untouched
default), it needs to end up tracked in this repo as a stow package** —
either move the real file in and re-`stow` it, or, if it's already a
symlink into `~/.dotfiles`, just edit it directly (both paths are the same
file). Don't leave hand-edited config living only on disk on one machine.

Nothing here overrides the user's global `~/.claude/CLAUDE.md` — this file
only adds repo-specific context.
