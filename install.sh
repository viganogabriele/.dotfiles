#!/usr/bin/env bash

# --- Environment Setup ---
# Use absolute path to ensure the script works regardless of where it's called
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_FOLDERS=("ghostty" "hypr" "swayosd" "walker" "waybar" "xcompose" "zsh" "personal" "uwsm")
SEP='\n------------------------------------\n'

# Logging helpers
log() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; exit 1; }

echo -e $SEP
log "Starting Omarchy setup. Let's make it solid."
echo -e $SEP

# --- 1. System Check ---
# Safety first: check if we are on Arch
[[ -f /etc/arch-release ]] || error "This script only supports Arch Linux."

# --- 2. Base System Update ---
log "Updating system and installing core tools..."
sudo pacman -Syu --needed --noconfirm base-devel git stow zsh

# --- 3. AUR Helper (yay) ---
# Install yay if missing to handle AUR packages
if ! command -v yay &> /dev/null; then
    log "Yay not found. Installing from source..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay && makepkg -si --noconfirm && popd
    rm -rf /tmp/yay
fi

# --- 4. Package Installation ---
log "Installing packages from lists..."
# Install native packages from the official repos
if [[ -f "$DOTFILES/pkglist_native.txt" ]]; then
    sudo pacman -S --needed --noconfirm - < "$DOTFILES/pkglist_native.txt" || warn "Some native packages failed to install."
fi

# Install AUR packages using yay
if [[ -f "$DOTFILES/pkglist_aur.txt" ]]; then
    yay -S --needed --noconfirm - < "$DOTFILES/pkglist_aur.txt" || warn "Some AUR packages failed to install."
fi

# --- 5. Boot & Kernel Maintenance ---
log "Ensuring kernel headers and boot images are ready..."
sudo pacman -S --needed --noconfirm linux-headers

# Support for Limine or standard mkinitcpio
if command -v limine-update &> /dev/null; then
    sudo limine-update
else
    sudo mkinitcpio -P
fi

# --- 6. Development Tools ---
# Ensure pnpm is available for JS/TS projects
if ! command -v pnpm &> /dev/null; then
    log "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# Setup Oh My Zsh if not already present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- 7. Dotfiles Deployment (GNU Stow) ---
log "Linking dotfiles with GNU Stow..."
pushd "$DOTFILES" > /dev/null
for folder in "${STOW_FOLDERS[@]}"; do
    log "Processing module: $folder"
    
    # Identify real files blocking the symlinks and back them up
    stow -n -v "$folder" 2>&1 | grep "existing target" | sed 's/.*existing target //' | sed 's/ since.*//' | while read -r conflict; do
        conflict=$(echo "$conflict" | xargs)
        target="$HOME/$conflict"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            warn "Conflict: $target is a real file. Backing it up to .bak"
            mv "$target" "$target.bak"
        fi
    done

    # Remove old links (if any) and apply new ones
    stow -D "$folder" 2>/dev/null
    stow "$folder"
done
popd > /dev/null

# --- 8. VS Code Extensions ---
if command -v code &> /dev/null && [[ -f "$DOTFILES/vscode_extensions.txt" ]]; then
    log "Syncing VS Code extensions..."
    while read -r ext; do
        [[ -z "$ext" ]] && continue
        code --install-extension "$ext" --force &>/dev/null
    done < "$DOTFILES/vscode_extensions.txt"
fi

# --- 9. Finalization ---
log "Finalizing system configuration..."
# Ensure maintenance scripts are executable
chmod +x "$DOTFILES/sync.sh" "$DOTFILES/refresh_lists.sh"

# Refresh font cache
fc-cache -f

# Ensure zsh is the default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
    log "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

echo -e $SEP
log "Setup complete! Please REBOOT to apply all changes."
echo -e $SEP