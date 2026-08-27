---
name: feedback-omarchy-official-packages
description: "Prefer Omarchy's own repo packages/defaults over AUR/git alternatives for components Omarchy curates"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 12dd155b-a8b5-462e-a408-b92a68af44c6
  modified: 2026-08-22T10:40:08.715Z
---

When maintaining this Omarchy system, prefer packages and defaults provided by the `omarchy` repo/project itself over AUR or `-git` alternatives, when both exist for the same component.

**Why:** Omarchy curates specific package versions (e.g. `quickshell-git` from the `omarchy` repo) to stay in sync with the rest of its stack. On 2026-08-21, a background agent installed `quickshell-git` from AUR instead of the `omarchy` repo build; that AUR build was pinned to an older Qt6 ABI and broke (`symbol lookup error`, shell crash, SUPER+SPACE / bar menu dead) the next time Qt6 got a routine point update via `omarchy update` on 2026-08-22. Reinstalling from the `omarchy` repo (`pacman -S omarchy/quickshell-git`) fixed it. The user's own regular `omarchy update` flow is not the failure mode here — ad hoc AUR installs of components Omarchy already ships are.

**How to apply:** Before installing/upgrading a component that both AUR and the `omarchy` repo provide (quickshell/quickshell-git is the known case, likely others), check if Omarchy already ships it and use that version. Avoid `yay -S <pkg>-git` as a "fix" for an Omarchy-managed component unless there's no repo alternative — it detaches that package from Omarchy's own update/compatibility tracking and can reintroduce the same breakage on the next routine Qt/library bump. Multiple parallel agent sessions on this machine can each touch system packages independently — when diagnosing a fresh breakage, check `/var/log/pacman.log` for what changed recently, including from other sessions, before assuming the current task caused it.
