#!/usr/bin/env bash

# --- Environment Setup ---
# Get the absolute path of the script directory to ensure portability
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log() { echo -e "\033[0;32m[INFO]\033[0m $1"; }

echo "------------------------------------"
log "Refreshing package and extension lists..."

# Save native packages (official repos) - Sorted to keep git diffs clean
pacman -Qqen | sort > "$DOTFILES/pkglist_native.txt"

# Save AUR packages (foreign) - Sorted alphabetically
pacman -Qqem | sort > "$DOTFILES/pkglist_aur.txt"

# Save VS Code extensions if code is installed
if command -v code &> /dev/null; then
    # Sorting extensions avoids unnecessary changes in the file
    code --list-extensions | sort > "$DOTFILES/vscode_extensions.txt"
    log "VS Code extensions list updated."
else
    log "VS Code not found, skipping extension list."
fi

log "All lists updated successfully in $DOTFILES."
echo "------------------------------------"