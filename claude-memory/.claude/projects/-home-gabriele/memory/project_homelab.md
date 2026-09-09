---
name: project-homelab
description: "State and plan of the home server/network homelab (TrueNAS, Proxmox, printer migration, VPN) — Notion doc \"Contesto Homelab per Agenti\""
metadata: 
  node_type: memory
  type: project
  originSessionId: ff23ff9b-d194-4ae9-a5f4-8b71ba66b601
  modified: 2026-09-07T21:22:17.350Z
---

Home network/server infra in transition, tracked in Notion page "🤖 Contesto Homelab per Agenti" (child of "Server & Rete Domestica", https://app.notion.com/p/3d4e2c96359e815da620f9f2b5033ca7). Homelab running since Dec 2025; shared storage used by 6 family members.

**Why:** old Windows 10 server (EOL) is being replaced by TrueNAS + Proxmox containers; user is mid-migration, not finished.

**Current topology:**
- Server-vecchio (Win10 EOL, 192.168.1.2): still live, shares data + distributes printer drivers via a custom installer exe
- Server-QNAP (192.168.1.249): backup of Server-vecchio. A second backup NAS is suspected but unverified (possibly dead disk/powered off)
- TrueNAS-A (192.168.1.5, i7-4790/16GB, TrueNAS CE 25.10.7): ready, RAIDZ1 4x4TB (~9.71TiB), pool `zpool` / dataset `file`, encrypted GDrive backup active, 2FA on, SSH off by default. Datasets: `scansioni` (migrated), `gabriele` (personal, DO NOT TOUCH), `archivio`/`scambio` (still to migrate from Server-vecchio via robocopy — previous attempt failed)
- TrueNAS-B: not installed yet — planned as local ZFS replica node, only after ~1 month hybrid rodaggio
- Proxmox miniPC (192.168.1.6) LXC containers: CUPS (.11, must replace Windows driver distribution for Plotter .150 and Stampante-Generic .201 — needs reverse-engineering the old installer), WireGuard VPN (.8, off by default, started via Telegram bot at .9 — repo github.com/viganogabriele/telegram-proxmox-vpn — to minimize attack surface), Home Assistant (.7)

**Plan order:** 1) migrate archivio/scambio to TrueNAS-A, 2) replace printer driver distribution with CUPS, 3) ~1 month hybrid rodaggio (Server-vecchio as fallback), 4) solid physical-disk backup then decommission Server-vecchio + install TrueNAS-B, 5) later: monitoring (Uptime Kuma + Prometheus/Grafana)

**Open questions (as of 2026-09-07):** identity/status of the second backup NAS; exact printer models/drivers for CUPS config; where credentials live (1Password, which vaults); which datasets utente_studio/utente_limitato map to; whether the GDrive Cloud Sync (re-enabled 2026-09-07 after ~10 months off) completes successfully next run. Also noted: one failed login attempt on TrueNAS-A on 2026-09-06 evening, likely a typo but worth watching.

**How to apply:** Before suggesting homelab changes, check this reflects current state — re-fetch the Notion page if the user references recent progress, since this snapshot is frozen at 2026-09-07.
