#!/usr/bin/env bash
set -uo pipefail
# (not -e: several steps intentionally continue past failure with warn())

# --- Environment Setup ---
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEP='\n------------------------------------\n'

# Logging helpers
log() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; exit 1; }

# --- Stow package discovery ---
# Any top-level folder here becomes a stow package automatically — no array
# to remember to update. Add exceptions below instead of hardcoding a list.
#
# RETIRED_FOLDERS: kept in the repo for reference but no longer linked
# (superseded by an Omarchy upgrade — see OMARCHY-QUATTRO-MIGRATION.md).
RETIRED_FOLDERS=("waybar" "walker" "swayosd")
# NON_STOW_FOLDERS: not $HOME configs — installed by a dedicated step below.
NON_STOW_FOLDERS=("system")
# battery/ and kbd-backlight/ are linked everywhere (so both machines can
# keep syncing the same files), but their systemd units are only ENABLED
# where the relevant hardware exists — see step 8c below.
# NO_FOLD_FOLDERS: stowed with --no-folding. Needed for packages that
# contain their own relative symlinks (e.g. nvim's Omarchy theme hook) whose
# target depth would break if stow collapsed the whole directory into one
# symlink instead of mirroring it file-by-file.
NO_FOLD_FOLDERS=("nvim")

is_in() { local needle="$1"; shift; local x; for x in "$@"; do [[ "$x" == "$needle" ]] && return 0; done; return 1; }

STOW_FOLDERS=()
for entry in "$DOTFILES"/*/; do
    folder="$(basename "$entry")"
    is_in "$folder" "${RETIRED_FOLDERS[@]}" && continue
    is_in "$folder" "${NON_STOW_FOLDERS[@]}" && continue
    STOW_FOLDERS+=("$folder")
done

echo -e $SEP
log "Starting Omarchy setup. Let's make it solid."
log "Stow packages found: ${STOW_FOLDERS[*]}"
echo -e $SEP

# --- 1. System Check ---
[[ -f /etc/arch-release ]] || error "This script only supports Arch Linux."

# --- 2. Pull latest dotfiles first ---
# Running install.sh IS how you re-sync a machine, so always start from the
# latest committed state before doing anything else.
if [[ -d "$DOTFILES/.git" ]]; then
    log "Pulling latest dotfiles..."
    git -C "$DOTFILES" pull --rebase origin main || warn "git pull failed, continuing with local state."
fi

# --- 3. Base System Update ---
log "Updating system and installing core tools..."
sudo pacman -Syu --needed --noconfirm base-devel git stow zsh

# --- 4. AUR Helper (yay) ---
if ! command -v yay &> /dev/null; then
    log "Yay not found. Installing from source..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm) || error "Failed to build yay."
    rm -rf /tmp/yay
fi

# --- 5. Package Installation ---
log "Installing packages from lists..."
if [[ -f "$DOTFILES/pkglist_native.txt" ]]; then
    sudo pacman -S --needed --noconfirm - < "$DOTFILES/pkglist_native.txt" || warn "Some native packages failed to install."
fi
if [[ -f "$DOTFILES/pkglist_aur.txt" ]]; then
    yay -S --needed --noconfirm - < "$DOTFILES/pkglist_aur.txt" || warn "Some AUR packages failed to install."
fi

# --- 5b. Prune packages no longer tracked ---
# Converges an older/differently-provisioned machine to the same package set:
# anything explicitly installed here but absent from both pkglists gets
# flagged. NEVER auto-removed — pacman asks for confirmation on the removal
# transaction itself, and some of these may be legitimate machine-specific
# packages (GPU drivers, wifi firmware helpers...) that simply never belonged
# in the shared list. Review the list before confirming.
log "Checking for packages installed here but no longer tracked in this repo..."
{
    [[ -f "$DOTFILES/pkglist_native.txt" ]] && cat "$DOTFILES/pkglist_native.txt"
    [[ -f "$DOTFILES/pkglist_aur.txt" ]] && cat "$DOTFILES/pkglist_aur.txt"
} | sort -u > /tmp/dotfiles-pkglist-wanted.txt
pacman -Qqe | sort -u > /tmp/dotfiles-pkglist-installed.txt
ORPHANS=$(comm -23 /tmp/dotfiles-pkglist-installed.txt /tmp/dotfiles-pkglist-wanted.txt)
rm -f /tmp/dotfiles-pkglist-wanted.txt /tmp/dotfiles-pkglist-installed.txt
if [[ -n "$ORPHANS" ]]; then
    warn "These packages are installed but not in pkglist_native.txt / pkglist_aur.txt:"
    echo "$ORPHANS" | while read -r pkg; do
        desc=$(pacman -Qi "$pkg" 2>/dev/null | awk -F': ' '/^Description/{print $2}')
        echo "  - $pkg  ($desc)"
    done
    warn "Some of these may be legitimate to THIS machine (drivers, firmware) rather than truly obsolete."
    read -r -p "Remove them now with pacman -Rns? [y/N] " reply
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        # shellcheck disable=SC2086
        sudo pacman -Rns $ORPHANS
    else
        log "Skipped removal."
    fi
else
    log "No orphan packages found."
fi

# --- 6. Boot & Kernel Maintenance ---
log "Ensuring kernel headers and boot images are ready..."
sudo pacman -S --needed --noconfirm linux-headers
if command -v limine-update &> /dev/null; then
    sudo limine-update
else
    sudo mkinitcpio -P
fi

# --- 7. Development Tools ---
if ! command -v pnpm &> /dev/null; then
    log "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- 8. Dotfiles Deployment (GNU Stow) ---
log "Linking dotfiles with GNU Stow..."
pushd "$DOTFILES" > /dev/null || error "Could not cd into $DOTFILES"
for folder in "${STOW_FOLDERS[@]}"; do
    log "Processing module: $folder"

    stow_flags=()
    is_in "$folder" "${NO_FOLD_FOLDERS[@]}" && stow_flags+=(--no-folding)

    # Identify real files blocking the symlinks and back them up
    stow -n -v "${stow_flags[@]}" "$folder" 2>&1 | grep "existing target" | sed 's/.*existing target //' | sed 's/ since.*//' | while read -r conflict; do
        conflict=$(echo "$conflict" | xargs)
        target="$HOME/$conflict"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            warn "Conflict: $target is a real file. Backing it up to .bak"
            mv "$target" "$target.bak"
        fi
    done

    stow -D "${stow_flags[@]}" "$folder" 2>/dev/null
    stow "${stow_flags[@]}" "$folder" || warn "Failed to stow $folder"
done
popd > /dev/null || warn "popd failed"

# --- 8b. Omarchy nvim theme hook ---
# lua/plugins/theme.lua is excluded from the nvim package itself (see
# nvim/.stow-local-ignore — GNU Stow can't manage a package source item that
# is itself a symlink) and recreated here instead: an absolute symlink into
# Omarchy's live theme state, identical on every machine.
if is_in "nvim" "${STOW_FOLDERS[@]}" && [[ -d "$HOME/.config/nvim/lua/plugins" ]]; then
    ln -sfn "$HOME/.local/state/omarchy/current/theme/neovim.lua" "$HOME/.config/nvim/lua/plugins/theme.lua"
fi

# --- 8c. Laptop-only services ---
# Files are linked on every machine (so they can keep being edited/synced
# from either one); the systemd timers behind them are only enabled where
# the hardware they act on actually exists.
IS_LAPTOP=false
if compgen -G "/sys/class/power_supply/BAT*" > /dev/null 2>&1; then
    IS_LAPTOP=true
fi

if is_in "battery" "${STOW_FOLDERS[@]}"; then
    if $IS_LAPTOP; then
        log "Battery present: enabling battery-monitor timer."
        systemctl --user enable --now omarchy-battery-monitor.timer 2>&1 || warn "Could not enable battery-monitor timer."
    else
        log "No battery detected: leaving battery-monitor timer disabled (desktop)."
        systemctl --user disable --now omarchy-battery-monitor.timer 2>/dev/null || true
    fi
fi

if is_in "kbd-backlight" "${STOW_FOLDERS[@]}"; then
    if compgen -G "/sys/class/leds/*kbd_backlight*" > /dev/null 2>&1; then
        log "Keyboard backlight detected: enabling kbd-backlight timers."
        systemctl --user enable --now omarchy-kbd-backlight-on.timer omarchy-kbd-backlight-off.timer 2>&1 || warn "Could not enable kbd-backlight timers."
    else
        log "No keyboard backlight device: leaving kbd-backlight timers disabled."
        systemctl --user disable --now omarchy-kbd-backlight-on.timer omarchy-kbd-backlight-off.timer 2>/dev/null || true
    fi
fi

if is_in "nightlight" "${STOW_FOLDERS[@]}"; then
    log "Enabling nightlight timers."
    systemctl --user enable --now omarchy-nightlight-on.timer omarchy-nightlight-off.timer 2>&1 || warn "Could not enable nightlight timers."
fi

systemctl --user daemon-reload 2>/dev/null || true

# --- 9. VS Code Extensions ---
if command -v code &> /dev/null && [[ -f "$DOTFILES/vscode_extensions.txt" ]]; then
    log "Syncing VS Code extensions..."
    while read -r ext; do
        [[ -z "$ext" ]] && continue
        code --install-extension "$ext" --force &>/dev/null
    done < "$DOTFILES/vscode_extensions.txt"
fi

# --- 9b. System files (outside $HOME, can't be stowed) ---
log "Installing system-level fixes (udev rules, helper scripts)..."
if [[ -f "$DOTFILES/system/bin/fixnet-flap.sh" ]]; then
    sudo install -m 755 "$DOTFILES/system/bin/fixnet-flap.sh" /usr/local/bin/fixnet-flap.sh
fi
if [[ -f "$DOTFILES/system/udev/99-ethernet-fix.rules" ]]; then
    sudo install -m 644 "$DOTFILES/system/udev/99-ethernet-fix.rules" /etc/udev/rules.d/99-ethernet-fix.rules
    sudo udevadm control --reload-rules
fi

# --- 10. Finalization ---
log "Finalizing system configuration..."
chmod +x "$DOTFILES/sync.sh" "$DOTFILES/refresh_lists.sh"
fc-cache -f

if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    log "Changing default shell to zsh..."
    chsh -s "$(command -v zsh)"
fi

echo -e $SEP
log "Setup complete! Please REBOOT to apply all changes."
echo -e $SEP
