#!/usr/bin/env bash
set -uo pipefail

# --- Environment Setup ---
# Use absolute paths to make the script runnable from anywhere
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEP='\n------------------------------------\n'

echo -e $SEP
echo "Starting Omarchy Sync Process..."
echo -e $SEP

cd "$DOTFILES" || { echo "ERROR: cannot cd into $DOTFILES"; exit 1; }

# --- 1. Update Package Lists ---
# Capture the current system state before anything else touches git.
if [[ -f "$DOTFILES/refresh_lists.sh" ]]; then
    bash "$DOTFILES/refresh_lists.sh"
else
    echo "ERROR: refresh_lists.sh not found!"
    exit 1
fi

# --- 2. Stage + Security Check (Gitleaks) ---
# Stage first so Gitleaks scans what's actually about to be committed
# ("protect --staged" diffs the index, unlike "detect" which scans commit
# history — scanning history here would miss secrets in these new changes
# entirely, since they wouldn't be in a commit yet).
git add .
if command -v gitleaks &> /dev/null; then
    if ! gitleaks protect --source "$DOTFILES" --staged -v; then
        echo "ERROR: Leaks detected in staged changes! Fix them before syncing."
        git restore --staged .
        exit 1
    fi
else
    echo "[WARN] Gitleaks not found, skipping security check."
fi

# --- 3. Commit local changes (if any) ---
if [[ -n $(git status --porcelain) ]]; then
    COMMIT_TIME=$(date +'%Y-%m-%d %H:%M:%S')
    git commit -m "Sync: $COMMIT_TIME - Automatical update"
else
    echo "No local changes to commit."
fi

# --- 4. Sync with Remote ---
# Pull (rebase) AFTER committing, so a dirty index never blocks the pull —
# any local commit just gets replayed on top of whatever's new upstream.
echo "Fetching latest changes from GitHub..."
if ! git pull --rebase origin main; then
    echo "ERROR: git pull --rebase failed (conflict?). Resolve manually, then re-run."
    exit 1
fi

# --- 5. Push ---
LOCAL_REV=$(git rev-parse HEAD)
REMOTE_REV=$(git rev-parse '@{u}' 2>/dev/null || echo "")
if [[ -z "$REMOTE_REV" || "$LOCAL_REV" != "$REMOTE_REV" ]]; then
    echo "Pushing to GitHub..."
    if git push origin main; then
        echo -e $SEP
        echo "Backup complete! Omarchy is up to date."
    else
        echo "ERROR: Git push failed."
        exit 1
    fi
else
    echo -e $SEP
    echo "Nothing to push. System is already synced."
fi