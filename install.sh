#!/usr/bin/env bash

# --- Environment Setup ---
DOTFILES=$HOME/.dotfiles
STOW_FOLDERS=("ghostty" "hypr" "swayosd" "walker" "waybar" "xcompose" "zsh")
SEP='\n------------------------------------\n'

# Logging helpers
log() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; exit 1; }

echo -e $SEP
log "Starting Omarchy setup. Let's make it solid."
echo -e $SEP

# --- 1. System Check ---
# Ensure we are actually running on Arch
[[ -f /etc/arch-release ]] || error "This script only supports Arch Linux."

# --- 2. Base System Update ---
log "Updating system and installing core tools..."
sudo pacman -Syu --needed --noconfirm base-devel git stow zsh

# --- 3. AUR Helper (yay) ---
# Bootstrap yay if it's missing
if ! command -v yay &> /dev/null; then
    log "Yay not found. Installing from source..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay && makepkg -si --noconfirm && popd
    rm -rf /tmp/yay
fi

# --- 4. Package Installation ---
log "Installing packages from native and AUR lists..."
if [[ -f "$DOTFILES/pkglist_native.txt" ]]; then
    # Use bulk install but ignore missing targets to avoid crashes
    sudo pacman -S --needed --noconfirm $(cat "$DOTFILES/pkglist_native.txt" | xargs) 2>/dev/null || warn "Some native packages skipped."
fi

if [[ -f "$DOTFILES/pkglist_aur.txt" ]]; then
    yay -S --needed --noconfirm - < "$DOTFILES/pkglist_aur.txt"
fi

# --- 5. Kernel Maintenance ---
# Keep the boot process stable
log "Ensuring kernel headers and boot images are ready..."
sudo pacman -S --needed --noconfirm linux-headers
if command -v limine-update &> /dev/null; then
    sudo limine-update
else
    sudo mkinitcpio -P
fi

# --- 6. Shell & Dev Tools ---
if ! command -v pnpm &> /dev/null; then
    log "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh (unattended)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- 7. Dotfiles Deployment (The Conflict Solver) ---
log "Linking dotfiles with GNU Stow..."
pushd "$DOTFILES"
for folder in "${STOW_FOLDERS[@]}"; do
    log "Processing module: $folder"
    
    # Detect files that would block stow and back them up
    stow -n -v "$folder" 2>&1 | grep "existing target" | sed 's/.*existing target //' | sed 's/ since.*//' | while read -r conflict; do
        conflict=$(echo "$conflict" | xargs)
        target="$HOME/$conflict"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            warn "Conflict found. Backing up $target to $target.bak"
            mv "$target" "$target.bak"
        fi
    done

    # Clean up old links and apply new ones
    stow -D "$folder" 2>/dev/null
    stow "$folder"
done
popd

# --- 8. VS Code Sync ---
if command -v code &> /dev/null && [[ -f "$DOTFILES/vscode_extensions.txt" ]]; then
    log "Syncing VS Code extensions..."
    while read -r ext; do
        code --install-extension "$ext" --force &>/dev/null
    done < "$DOTFILES/vscode_extensions.txt"
fi

# --- 9. Final Permissions and Shell ---
log "Finalizing system configuration..."
[[ -f "$DOTFILES/sync.sh" ]] && chmod +x "$DOTFILES/sync.sh"
fc-cache -f

# Switch default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s "$(which zsh)"
fi

echo -e $SEP
log "Setup complete! Your configurations are now active."
log "Please REBOOT to apply keyboard layout, themes, and bindings."