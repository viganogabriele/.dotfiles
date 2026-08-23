---
name: repo-hero
description: >
  Create a hero/preview/header image for a GitHub repository or an Omarchy
  plugin marketplace listing — a 1200x675 preview.png, README banner, or
  social-preview image that combines real screenshots with a headline,
  feature bullets, and an install command. Triggers: "crea un'immagine per
  la repo", "preview.png", "header per github", "immagine hero", "social
  preview", "marketplace image", "banner per il repo", "card del plugin".
  Use for Omarchy plugins and for any other GitHub project that wants a
  polished, screenshot-driven header.
---

# Repo hero image

Produces a polished 1200x675 hero image out of a project's *real*
screenshots — never a hand-drawn mockup — rendered through headless
Chromium so text stays crisp. Built from doing this for
`viganogabriele/agent-usage-plus`'s marketplace `preview.png`.

## Core principles (non-negotiable)

1. **Real screenshots only.** Capture the actual running app/plugin. A
   mockup reads as fake the moment someone compares it to the real thing.
2. **One visual hierarchy, deliberately chosen.** Ask (or infer from the
   README) which single feature is the headline feature, then make *that*
   screenshot the biggest/most prominent element — stronger border, brighter
   glow, bigger scale. Everything else is visibly secondary (smaller, more
   muted border). Don't render every screenshot at the same visual weight.
3. **Coordinate with the owner's existing brand**, if they have one (a
   personal site, an existing app theme). Pull real hex values from their
   site's shipped CSS — don't guess or eyeball colors from a screenshot.
   See "Brand palette" below for how, and for this user's cached palette.
4. **Verify factual claims before writing copy.** If the image credits an
   upstream/fork relationship, an author, or a stat, check the actual
   source (manifest.json, LICENSE, the original repo) — don't assume the
   README's phrasing is precise enough to lift verbatim into marketing copy.
5. **Explain non-obvious UI in a caption.** If a screenshot shows something
   that isn't self-explanatory (a tick mark on a meter, an icon whose
   meaning isn't obvious), add a short caption near it instead of leaving
   the viewer to guess.
6. **No unrelated content bleeding into a screenshot.** Neighboring bar
   icons, other windows, terminal output with private content — crop it out
   or, better, capture on an empty desktop/workspace so there's nothing to
   crop out. See "Capturing clean screenshots" below.

## Workflow

1. **Gather the brand palette.** If the repo owner has a personal site or
   an established brand, fetch its CSS and pull real color values (see
   below). Otherwise fall back to the template's default palette or ask.
2. **Decide the hierarchy.** One primary screenshot (big, glowing border),
   N secondary screenshots (smaller, quieter border). Read the README/
   manifest to find the feature the project actually leads with — don't
   guess from the file list.
3. **Capture screenshots** — see "Capturing clean screenshots" below if
   live desktop capture is needed.
4. **Crop precisely.** Never eyeball a crop box. Sample pixel colors along
   a line to find the exact border coordinates, then crop, then optionally
   `-trim` with a small `-fuzz` to auto-tighten:
   ```bash
   magick file.png -format "%[pixel:p{X,Y}]" info:   # sample a point
   magick file.png -crop WxH+X+Y +repage out.png     # crop to known bounds
   magick out.png -bordercolor "srgb(R,G,B)" -border 10 -fuzz 2% -trim +repage out.png
   ```
   Start the crop box exactly at the real UI border, not a few px outside
   it — trim only strips *contiguous matching background*, so if the crop
   box already includes wallpaper/other content touching the edge, trim
   won't remove it.
5. **Write `config.json`** (schema below) with the verified copy, the
   chosen hierarchy, and the cropped image paths.
6. **Render:**
   ```bash
   python3 ~/.claude/skills/repo-hero/generate_hero.py config.json preview.png
   ```
7. **Show the result to the user on their own screen** — don't just
   describe it in text:
   ```bash
   imv preview.png &   # or: xdg-open preview.png
   ```
8. **Ask before touching the repo.** Renaming an existing root `preview.png`
   (it may be referenced elsewhere, e.g. in the README), editing the
   README, committing, and pushing are all separate confirmations — don't
   bundle them into "done" without asking. See "Omarchy marketplace specifics"
   below for why a rename is often needed.

## Capturing clean screenshots

Getting a screenshot with nothing but the app on a clean background:

1. **Notify before touching the user's screen.** Switching workspaces or
   moving windows is disruptive if they're mid-task. Send a real desktop
   notification (not just a chat message — they may not be looking at the
   terminal) before acting, and again when done:
   ```bash
   notify-send "Claude Code" "Sto per passare a una workspace vuota per fare degli screenshot — torno subito."
   # ... do the capture ...
   notify-send "Claude Code" "Ho finito con lo schermo, puoi continuare."
   ```
2. **Don't assume standard Hyprland keybinds work.** Custom setups (Lua
   dispatch layers, workspace-manager plugins like a "spaces" sidebar) can
   intercept `Super+<digit>` and send you somewhere unexpected. If a
   workspace switch doesn't land where expected, **stop trying keybinds
   blindly** — you're now sending unpredictable input to a live session.
   Ask the user how to switch, or ask them to switch manually and tell you
   when ready. An empty workspace with 0 windows is harmless to land on by
   accident; don't worry about that part, just stop guessing after one
   failed attempt.
3. Once on a clean desktop, use `grim` for full-screen capture, then IPC
   into the app/plugin (e.g. `omarchy-shell <target> open`, `... next` to
   cycle tabs) to get each state you need, screenshotting after each.
4. Crop with the pixel-sampling method above — even on an empty desktop,
   crop tight to the actual UI element to avoid capturing the wallpaper as
   if it were part of the design.

## Brand palette

Pull real values instead of guessing:

```bash
curl -sL "https://example.com" -o site.html
grep -oE 'href="[^"]*\.css[^"]*"' site.html          # find the bundled CSS
curl -sL "https://example.com/assets/whatever.css" -o site.css
grep -oE '#[0-9a-fA-F]{3,8}' site.css | sort | uniq -c | sort -rn   # dominant colors
grep -oE '\-\-color-[a-z]+:#[0-9a-fA-F]+' site.css   # named CSS variables, if any
grep -oE 'font-family:[^;}]+' site.css | sort -u      # fonts in use
```

**This user's site (viganogabriele.com), already extracted — reuse this,
only re-fetch if the site has visibly changed:**

| Token | Value | Role |
|---|---|---|
| `COLOR_BG` | `#080b16` | base background |
| `COLOR_SURFACE` | `#101427` | card/surface background |
| `COLOR_ACCENT1` | `#78a9ff` | blue — primary accent (headline highlight, primary border) |
| `COLOR_ACCENT2` | `#a68bff` | violet — secondary accent (glow, secondary borders) |
| `COLOR_TEXT` | `#edf1ff` | headline text |
| `COLOR_MUTED` | `#929bb5` | labels, footer |

Fonts: **Space Grotesk** (headings/body), **Space Mono** (labels, code,
footer command) — both pulled live from Google Fonts in `template.html`,
no local install needed.

These are the template's defaults (`generate_hero.py`'s `DEFAULT_PALETTE`).
Override per-project via `config.json`'s `"palette"` key only when a
project should look distinctly different from this default.

## config.json schema

```json
{
  "category": "WIDGETS",
  "author": "VIGANOGABRIELE",
  "credit_line": "Fork of Omarchy's built-in Agents widget (omarchy.agents), by Basecamp.",
  "headline_html": "Every subscription&rsquo;s pace,<br>right in the <span class=\"accent\">bar</span>.",
  "description_html": "...",
  "bullets_html": ["Live meter <b>+ percent</b> per subscription", "..."],
  "footer_cmd": "omarchy plugin add",
  "footer_repo": "github.com/you/your-plugin",
  "hero_image": "bar_widget.png",
  "hero_caption_html": "Explain anything non-obvious in the hero shot here.",
  "panel_images": [{ "path": "claude_tab.png" }, { "path": "codex_tab.png" }],
  "palette": { "COLOR_ACCENT1": "#ff8844" },
  "layout": { "HERO_W": 460, "PANEL_H": 280 }
}
```

- All image paths resolve relative to `config.json`'s own directory.
- `panel_images` renders left-to-right in a row below the hero shot, at
  equal height (`layout.PANEL_H`), width following each image's own aspect
  ratio — so don't force different aspect ratios into that row or they'll
  look mismatched.
- `palette` and `layout` are both optional partial overrides merged onto
  the defaults in `generate_hero.py`.
- See `~/Work/templates/plugin-hero/examples/agent-usage-plus/` for a
  complete worked example (config + cropped screenshots + rendered output).

## Omarchy marketplace specifics

If this hero image is meant to be the plugin's **marketplace listing
image**, the marketplace auto-detects a root file literally named
`preview.png` (or `.jpg`/`.jpeg`/`.webp`/`.avif`) and auto-generates card +
detail crops from it — 1200x675 (16:9) is a safe aspect ratio for that.

If the repo *already* has a `preview.png` referenced elsewhere (commonly in
the README, alongside other plain screenshots for documentation purposes),
don't just overwrite it — that breaks those references. Rename the old file
(e.g. `preview.png` → `preview-claude.png`) and update the README's `<img>`/
`![]()` references to match, *then* write the new hero image as `preview.png`.
Always show the rename + README diff and get confirmation before doing it —
this is a repo-changing action, not just an image-generation one.
