---
name: user-laptop-power-prefs
description: "Power/battery preferences on the LG Gram 15Z90S laptop — charge to 100%, Wi-Fi powersave off, no TLP"
metadata: 
  node_type: memory
  type: user
  originSessionId: ba179b91-caa8-4a8c-9c73-619d248248f9
  modified: 2026-09-15T19:30:35.727Z
---

Laptop: LG Gram 15Z90S (Core Ultra 7 155H, Meteor Lake), Omarchy/Hyprland. Explicit, deliberate choices — do not "optimize" these away:

- **Battery charges to 100%.** `battery_care_limit` / `charge_control_end_threshold` stay at 100 by choice, even though the driver also accepts 80 and the battery is at ~84% health. Do not propose an 80% cap again.
- **Wi-Fi powersave stays off** (`/etc/NetworkManager/conf.d/omarchy-wifi-powersave.conf` → `wifi.powersave = 2`). Stability beats the ~0.4 W saving.
- **No TLP.** Removed 2026-09-15 in favour of power-profiles-daemon (Omarchy default), locked to `power-saver`. PPD has `PlatformDriver: placeholder` here — no ACPI platform_profile on the Gram — so it only drives governor + EPP.
- Usually runs with the internal panel **disabled** (hyprmoncfg) and only an external 2560x1080@100Hz ultrawide on HDMI, sometimes on battery. Internal backlight readings are meaningless in that state.

**Why:** an earlier AI session removed TLP and falsely claimed it had verified 75/80% charge thresholds that never existed on this hardware; the user then confirmed they actually want 100% and a stable Wi-Fi.

**How to apply:** when asked about battery life here, go after idle/DPMS behaviour, background daemons and GPU offload — not charge caps or radio powersave. See [[project-homelab]] for the rest of the machine context.
