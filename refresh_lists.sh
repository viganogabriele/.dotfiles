#!/usr/bin/env bash
set -uo pipefail

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

# Save third-party Omarchy plugins (marketplace, installed via `omarchy plugin
# add <git-url>`) as "id url" pairs, so install.sh can reinstall them
# elsewhere. Excludes our own plugins: those are tracked directly as stow
# packages/submodules (agents/, kdeconnect/, notes/, omarchy-workspaces/), not
# through this list.
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
if [[ -d "$PLUGINS_DIR" ]]; then
    : > "$DOTFILES/pkglist_omarchy_plugins.txt"
    for d in "$PLUGINS_DIR"/*/; do
        id="$(basename "${d%/}")"
        [[ "$id" == "gabriele.workspaces" ]] && continue
        url="$(git -C "$d" remote get-url origin 2>/dev/null || true)"
        [[ -z "$url" ]] && continue
        [[ "$url" == *viganogabriele* ]] && continue
        echo "$id $url" >> "$DOTFILES/pkglist_omarchy_plugins.txt"
    done
    sort -o "$DOTFILES/pkglist_omarchy_plugins.txt" "$DOTFILES/pkglist_omarchy_plugins.txt"
    log "Third-party Omarchy plugin list updated."
fi

log "All lists updated successfully in $DOTFILES."
echo "------------------------------------"