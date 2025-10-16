#!/bin/bash

# Exit on any error
set -e

# --- Helper Functions for Logging ---
info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; exit 1; }

# --- Main Setup Logic ---
main() {
    # 1. Dependency Checks
    info "Checking dependencies..."
    command -v git >/dev/null 2>&1 || error "Git is not installed. Please install it first."
    command -v brew >/dev/null 2>&1 || error "Homebrew is not installed. Please install it from https://brew.sh/"
    command -v stow >/dev/null 2>&1 || { info "Stow not found. Installing with Homebrew..."; brew install stow; }

    # 2. Homebrew Package Installation
    info "Installing Homebrew packages..."
    
    # Tap cask for fonts
    brew tap homebrew/cask-fonts

    # Install Nerd Font
    brew install --cask font-fira-code-nerd-font font-meslo-lg-nerd-font

    # Install CLI tools and GUI Apps
    brew install fish starship atuin zoxide fzf fd ripgrep eza bat procs duf broot navi lazygit lazydocker fastfetch htop direnv jq
    brew install --cask wezterm zed zen raycast

    info "All packages installed."

    # 3. Stow Dotfiles
    info "Applying configurations by creating symlinks..."
    # Assumes this script is run from the root of the dotfiles repository
    stow --dir=stow --target=$HOME --restow common mac

    # 4. Change Default Shell to Fish
    info "Setting Fish as the default shell..."
    FISH_PATH="/opt/homebrew/bin/fish"
    if ! grep -Fxq "$FISH_PATH" /etc/shells; then
        info "Adding '$FISH_PATH' to /etc/shells. You may be prompted for your password."
        echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi
    if [ "$SHELL" != "$FISH_PATH" ]; then
        info "Changing your default shell to Fish. You may be prompted for your password."
        chsh -s "$FISH_PATH"
    else
        info "Default shell is already Fish."
    fi

    info "✅ Setup complete! Please restart your terminal or log out and back in for all changes to take effect."
}

# --- Run the main function ---
main
