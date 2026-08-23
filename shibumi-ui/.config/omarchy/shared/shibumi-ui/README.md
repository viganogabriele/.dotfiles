# shibumi-ui (vendored)

Selected QML components vendored from [Shibumi-Shell](https://github.com/HANCORE-linux/Shibumi-Shell)
(MIT license, see `LICENSE`), for reuse in my own Omarchy plugins without pulling in
the full 24-plugin Shibumi suite.

All files depend only on Omarchy's native `qs.Commons` / `qs.Ui` modules
(`/usr/share/omarchy/shell/{Commons,Ui}`), which already exist on this system — no
Shibumi core/services required.

## Genuinely new (worth using)

- **PillSurface.qml** — rounded "pill" background shape. Zero Shibumi-specific
  dependencies (just `QtQuick` + `QtQuick.Effects`). Drop-in usable in any widget.
- **ThemePalette.qml` + `ThemePaletteModel.js`** — parses the active Omarchy/terminal
  color scheme (color1..color8, pywal-style) into named tokens (`color01`..`color08`).
  This is the actual valuable piece: widgets built on it re-color themselves
  automatically when the Omarchy theme changes, instead of hardcoding colors.
- **IconText.qml** — tiny icon+label row helper, no dependencies.

## Just reskins of what Omarchy already ships natively

`ShibumiPanel`, `ShibumiDropdown`, `ShibumiButtonGroup`, `ShibumiSlider`,
`ShibumiTextField`, `ShibumiPanelToolTip`, `HostTokens` all wrap Omarchy's own
`qs.Ui.Panel` / `Dropdown` / `ButtonGroup` etc. with Shibumi's specific visual
styling. Kept here for reference/inspiration, not because they add capability
you don't already have via `qs.Ui`.

## Not yet portable as-is

`VisualTokens.qml` expects a `bar` context object (Shibumi's own bar-plugin
model) to read the active theme file path from — it won't work standalone
without adapting that input. `ThemePalette.qml` is the more self-contained
alternative for the same idea.

## Using from a plugin

These aren't a registered QML module (no `qmldir`) — import them by relative
file path from a plugin, e.g. from
`~/.config/omarchy/plugins/<your-plugin>/Panel.qml`:

```qml
import "../../shared/shibumi-ui/PillSurface.qml" as ShibumiUi
// or copy the specific .qml file directly into the plugin dir, which is
// what Shibumi itself does per-plugin (no cross-plugin shared import at runtime)
```

Source: https://github.com/HANCORE-linux/Shibumi-Shell (commit as of 2026-08-22).
