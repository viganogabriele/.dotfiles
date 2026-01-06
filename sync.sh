#!/usr/bin/env bash

# --- Environment Setup ---
DOTFILES=$HOME/.dotfiles
SEP='\n------------------------------------\n'

echo -e $SEP
echo "Starting Omarchy Sync Process..."
echo -e $SEP

# --- 1. Security Check (Gitleaks) ---
echo "Checking for secrets with Gitleaks..."
if ! gitleaks detect --source . -v; then
    echo "ERROR: Leaks detected! Fix them before pushing."
    exit 1
fi

# --- 2. Call the Refresh Script ---
# We call our modular script to update lists
if [[ -f "$DOTFILES/refresh_lists.sh" ]]; then
    bash "$DOTFILES/refresh_lists.sh"
else
    echo "ERROR: refresh_lists.sh not found!"
    exit 1
fi

# --- 3. Git Operations ---
echo "Pushing changes to GitHub..."
git add .

COMMIT_TIME=$(date +'%Y-%m-%d %H:%M:%S')
git commit -m "Sync: $COMMIT_TIME - Automatical update via dotsave"

if git push; then
    echo -e $SEP
    echo "Backup complete! Omarchy is up to date."
else
    echo "ERROR: Git push failed."
    exit 1
fi