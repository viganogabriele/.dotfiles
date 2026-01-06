markdown
# 🐧 My Omarchy Dotfiles

This repository contains my personal configurations for **Omarchy** (Arch Linux + Hyprland). I use `stow` to manage symlinks and a custom script to automate the setup on new machines.

## 🚀 Quick Start (New Machine)

If you are on a fresh Omarchy installation, just run these commands to replicate my setup:

```bash
# 1. Clone the repo
git clone git@github.com:viganogabriele/.dotfiles.git ~/.dotfiles

```

```bash
# 2. Go to the folder
cd ~/.dotfiles

```

```bash
# 3. Make the script executable and run it
chmod +x install.sh
./install.sh

```

The script will install all native and AUR packages, set up **Oh My Zsh**, install **pnpm**, and link all the config files.

---

## 🔄 How to keep everything synced

### 1. The Fast Way (Automated Sync)

I've created a synchronization script that handles everything for me. It checks for secrets using **Gitleaks**, updates package lists, and pushes to GitHub.

To use it, simply run:

```bash
dotsave

```

*(This is an alias for `~/.dotfiles/sync.sh` defined in my .zshrc)*

### 2. The Manual Way

If you prefer to do it manually or the script fails:

1. Update lists: `pacman -Qeq > pkglist_native.txt && yay -Qem > pkglist_aur.txt`
2. Check for leaks: `gitleaks detect --source . -v`
3. Push: `git add . && git commit -m "update" && git push`

### 3. Getting changes (Pulling on PC B)

When switching to another computer, just pull the latest changes:

```bash
cd ~/.dotfiles
git pull
# Run the install script to apply new configs or install new apps
./install.sh

```

---

## 🛡️ Security

This repo uses **Gitleaks** to prevent accidentally pushing sensitive data (API keys, passwords, etc.). The `sync.sh` script will automatically abort the push if any leak is detected.

---

## 📁 Project Structure

* `hypr/`, `waybar/`, `walker/`, `ghostty/`: App configurations.
* `zsh/`: Zsh settings and aliases.
* `sync.sh`: Safety-first synchronization script.
* `pkglist_*.txt`: Lists of all installed programs.