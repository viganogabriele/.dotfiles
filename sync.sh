#!/usr/bin/env bash

# --- Environment Setup ---
# Use absolute paths to make the script runnable from anywhere
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEP='\n------------------------------------\n'

echo -e $SEP
echo "Starting Omarchy Sync Process..."
echo -e $SEP

# --- 1. Sync with Remote ---
# Always pull first to avoid conflicts. 
# --rebase keeps your local changes on top of the history.
echo "Fetching latest changes from GitHub..."
git pull --rebase origin main

# --- 2. Security Check (Gitleaks) ---
echo "Checking for secrets with Gitleaks..."
if command -v gitleaks &> /dev/null; then
    if ! gitleaks detect --source "$DOTFILES" -v; then
        echo "ERROR: Leaks detected! Fix them before pushing."
        exit 1
    fi
else
    echo "[WARN] Gitleaks not found, skipping security check."
fi

# --- 3. Update Package Lists ---
# Ensure we are capturing the current system state
if [[ -f "$DOTFILES/refresh_lists.sh" ]]; then
    bash "$DOTFILES/refresh_lists.sh"
else
    echo "ERROR: refresh_lists.sh not found!"
    exit 1
fi

# --- 4. Git Operations ---
# Only commit and push if there are actual changes
if [[ -n $(git status --porcelain) ]]; then
    echo "Changes detected. Pushing to GitHub..."
    git add .
    COMMIT_TIME=$(date +'%Y-%m-%d %H:%M:%S')
    git commit -m "Sync: $COMMIT_TIME - Automatical update"
    
    if git push origin main; then
        echo -e $SEP
        echo "Backup complete! Omarchy is up to date."
    else
        echo "ERROR: Git push failed."
        exit 1
    fi
else
    echo "No changes detected. System is already synced."
fi