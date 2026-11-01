---
name: project-cloudflare-ddns-cutover
description: "Stato 2026-10-30 di migrazione No-IP->Cloudflare DDNS e OpenCloud diretto con Traefik + Pocket ID (cosa fatto, cosa manca)"
metadata:
  node_type: memory
  type: project
  originSessionId: 7e5289e8-4afb-4550-bb2c-cb1dbb5203fc
  modified: 2026-10-30T20:05:55.488Z
---

Migrazione homelab (vigab.cc su Cloudflare), sessione 2026-10-29/30. Dashboard di riferimento: /home/gabriele/homelab-overview.html (generata da subagent, contiene la checklist).

**Fatto:** DDNS Cloudflare (LXC 106, vpn.vigab.cc, solo IPv4, non proxied) e No-IP disattivato nel router; WireGuard testato da fuori con Endpoint vpn.vigab.cc. LXC 107 Pocket ID (192.168.1.14, auth.vigab.cc, admin con passkey su 1Password), LXC 108 Traefik (192.168.1.15, Let's Encrypt via DNS-01 con token separato "traefik-acme"). OpenCloud (LXC 105, 192.168.1.13, Docker in /opt/opencloud) collegato a Pocket ID via pocketid.yml, ruolo admin dal claim custom `roles=opencloudAdmin`; login OK in LAN dal laptop con /etc/hosts.

**Manca (cutover):** forward TCP 80/443 -> 192.168.1.15 sul router TIM; togliere solo l'hostname cloud.vigab.cc dal tunnel cloudflared su TrueNAS; DNS cloud e auth come CNAME -> vpn.vigab.cc (DNS only); test da dati mobili; NAT loopback da LAN; disattivare utente locale "admin" di OpenCloud; seconda passkey; pulire /etc/hosts del laptop; spegnere LXC 101 wireguard. Poi: migrare cloudflared su Proxmox.

**Why:** OpenCloud in diretto per evitare i limiti di banda/upload del tunnel Cloudflare.

**How to apply:** il router TIM filtra risposte DNS con IP privati (rebind), quindi auth.vigab.cc non risolve in LAN dal telefono/container (c'e' extra_hosts nel compose). Mai aprire 8080 (dashboard Traefik) ne' SMB. Backup config in /opt/opencloud/*.bak-pre-oidc e /root/opencloud-config-backup.tgz (LXC 105). Vedi [[project-homelab]].

**Aggiornamento 2026-10-30 (notte):** cartelle spostate da Gabriele in ~/dev/personal/. Docs privati: ~/dev/personal/homelab-docs, Astro Starlight in site/ (su `main`, pushato; merge fatto 2026-10-30, commit acafe24; vecchio generatore rimosso, hook pre-commit in .githooks per i segreti; 54 pagine IT task-first + traduzione EN fatta da un'altra AI ma non riletta; revisione tecnica di Sol corretta, rapporti in reports/). Repo PRIVATO github.com/viganogabriele/homelab-docs. Sito pubblico LIVE https://homelab.vigab.cc (repo pubblico github.com/viganogabriele/homelab in ~/dev/personal/homelab-site, Vercel, CNAME DNS only, creato da un'altra AI di Gabriele; verificato: nessun dato privato). Mappa interattiva v2 finale dentro docs/site/public/homelab-infrastructure.html. Docs in LAN: LXC Caddy/nginx su IP fisso (es. .20), script in deploy/; docs.vigab.cc "da decidere". SPF/DMARC/MX nullo su vigab.cc creati. Home Assistant = VM. Il Notion (8/9) e' in parte superato. Sol = `codex exec -m gpt-6.1-sol` (config di default gpt-6-luna). Se si spostano cartelle mentre un agente codex lavora il suo shell si rompe. Nessuna attribuzione Claude nei commit. **Cutover OpenCloud ANCORA da fare** (router 80/443 + Cloudflare: tunnel e CNAME cloud/auth), in attesa di Gabriele.
