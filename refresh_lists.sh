#!/usr/bin/env bash

# --- Environment Setup ---
DOTFILES=$HOME/.dotfiles
log() { echo -e "\033[0;32m[INFO]\033[0m $1"; }

echo "------------------------------------"
log "Refreshing package and extension lists..."

# Save native packages (official repos)
pacman -Qqen > "$DOTFILES/pkglist_native.txt"

# Save AUR packages
pacman -Qqem > "$DOTFILES/pkglist_aur.txt"

# Save VS Code extensions
if command -v code &> /dev/null; then
    code --list-extensions > "$DOTFILES/vscode_extensions.txt"
fi

log "All lists updated successfully."
echo "------------------------------------"