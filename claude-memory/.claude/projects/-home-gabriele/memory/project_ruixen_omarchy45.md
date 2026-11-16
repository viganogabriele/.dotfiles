---
name: project-ruixen-omarchy45
description: "Ruixen Shell upstream (f776784, Oct 2026) breaks on Omarchy 4.5; laptop stays on the pre-update Ruixen install"
metadata:
  node_type: memory
  type: project
  originSessionId: ec0dc172-c199-445e-a73d-ecb587cf7dd8
  modified: 2026-11-16T16:28:00.489Z
---

On 2026-11-16 updating Ruixen Shell (~/dev/omarchy/ruixen-shell) to upstream f776784 broke the bar on Omarchy 4.5 (TypeErrors: `hideTooltip`, `firstPartyServiceFor`, 120+ "invalid context"). Upstream COMPATIBILITY.md only verifies up to Omarchy 4.0.4. Rolled back to the previously installed plugins (incl. ruixen.settings, ruixen.frame-widget); broken install quarantined in ~/.local/state/ruixen-f776784-removed-*.

**Why:** the user called the updated shell "pieno di bug"; the old install runs clean on 4.5.
**How to apply:** don't run Ruixen's update.sh/install.sh again until COMPATIBILITY.md lists an Omarchy 4.5.x row; check that first, and back up ~/.config/omarchy/plugins/ruixen.*, shell.json and ~/.local/share/ruixen-shell before trying. The ~/dev/omarchy/ruixen-shell checkout is left at f776784 with the dock patch applied, so it does NOT match what's installed. Related: [[project-hacktrack]] (unrelated), dotfiles README "Ruixen Shell local fix".
