#!/usr/bin/env python3
"""Reusable Omarchy-plugin hero/preview image generator.

Renders a 1200x675 marketplace preview.png from a JSON config plus real
screenshots (no mockups) using headless Chromium, so text stays crisp and
selectable-looking instead of hand-drawn.

Usage:
    generate_hero.py config.json output.png

Config schema (see examples/agent-usage-plus.json):
{
  "category": "WIDGETS",
  "author": "YOURNAME",
  "credit_line": "Fork of Omarchy's built-in Agents widget.",
  "headline_html": "Every subscription&rsquo;s pace,<br>right in the <span class=\"accent\">bar</span>.",
  "description_html": "...",
  "bullets_html": ["Live meter <b>+ percent</b> per subscription", ...],
  "footer_cmd": "omarchy plugin add",
  "footer_repo": "github.com/you/your-plugin",
  "hero_image": "bar_widget.png",
  "hero_caption_html": "The <b>tick</b> marks the weekly percent riding on the session meter.",
  "panel_images": [{"path": "claude_tab.png", "label": "Claude Code"}, {"path": "codex_tab.png"}],
  "palette": { ... optional overrides, see DEFAULT_PALETTE below ... }
}

All image paths are resolved relative to the config file's directory.
"""
import base64
import json
import subprocess
import sys
from pathlib import Path
from string import Template

TEMPLATE_PATH = Path(__file__).parent / "template.html"

# Coordinated with viganogabriele.com's own palette (pulled from its bundled
# CSS): near-black navy base, blue+violet duotone accents, Space
# Grotesk/Space Mono type. Override per-project via config["palette"].
DEFAULT_PALETTE = {
    "COLOR_BG": "#080b16",
    "COLOR_SURFACE": "#101427",
    "COLOR_ACCENT1": "#78a9ff",   # blue
    "COLOR_ACCENT2": "#a68bff",   # violet
    "COLOR_TEXT": "#edf1ff",
    "COLOR_TEXT2": "#c7cbe0",
    "COLOR_MUTED": "#929bb5",
    "COLOR_MUTED2": "#a6adc8",
    "COLOR_CMD_TEXT": "#e8ecfa",
}

DEFAULT_LAYOUT = {
    "CANVAS_W": 1200,
    "CANVAS_H": 675,
    "PAD_X": 64,
    "PAD_Y": 52,
    "HEADLINE_SIZE": 42,
    "DESC_WIDTH": 480,
    "RIGHT_MARGIN": 70,
    "RIGHT_W": 430,
    "STACK_GAP": 16,
    "HERO_PAD": 14,
    "HERO_W": 420,
    "PANEL_H": 300,
}


def b64_image(path: Path) -> str:
    data = path.read_bytes()
    ext = path.suffix.lstrip(".").lower()
    mime = "png" if ext == "png" else ("jpeg" if ext in ("jpg", "jpeg") else ext)
    return f"data:image/{mime};base64,{base64.b64encode(data).decode()}"


def render(config_path: Path, output_path: Path) -> None:
    cfg = json.loads(config_path.read_text())
    base_dir = config_path.parent

    palette = {**DEFAULT_PALETTE, **cfg.get("palette", {})}
    layout = {**DEFAULT_LAYOUT, **cfg.get("layout", {})}

    bullets_html = "\n      ".join(f"<li>{b}</li>" for b in cfg["bullets_html"])

    panel_cards = []
    for p in cfg["panel_images"]:
        img_src = b64_image(base_dir / p["path"])
        panel_cards.append(f'<div class="panel-card"><img src="{img_src}"></div>')
    panels_html = "\n        ".join(panel_cards)

    hero_src = b64_image(base_dir / cfg["hero_image"])

    tokens = {
        **palette,
        **layout,
        "CATEGORY": cfg["category"],
        "AUTHOR": cfg["author"],
        "CREDIT_LINE": cfg.get("credit_line", ""),
        "HEADLINE_HTML": cfg["headline_html"],
        "DESCRIPTION_HTML": cfg["description_html"],
        "BULLETS_HTML": bullets_html,
        "FOOTER_CMD": cfg["footer_cmd"],
        "FOOTER_REPO": cfg["footer_repo"],
        "HERO_IMG_SRC": hero_src,
        "HERO_CAPTION_HTML": cfg.get("hero_caption_html", ""),
        "PANELS_HTML": panels_html,
    }

    html = Template(TEMPLATE_PATH.read_text()).safe_substitute(tokens)

    html_path = output_path.with_suffix(".source.html")
    html_path.write_text(html)

    subprocess.run(
        [
            "chromium", "--headless", "--disable-gpu", "--no-sandbox",
            "--hide-scrollbars",
            f"--window-size={layout['CANVAS_W']},{layout['CANVAS_H']}",
            f"--screenshot={output_path}",
            f"file://{html_path.resolve()}",
        ],
        check=True,
        capture_output=True,
    )
    print(f"wrote {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    render(Path(sys.argv[1]), Path(sys.argv[2]))
