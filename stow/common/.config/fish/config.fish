# Fish Shell Configuration
# Target: common
# Version: 1.1

# === Environment Variables ===
set -gx EDITOR "code --wait"
set -gx VISUAL "code --wait"
set -gx ALTERNATE_EDITOR "nvim"

# XDG Base Directories
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"

# Project Directories
set -gx NOTES_DIR "$HOME/notes"
set -gx PROJECTS_DIR "$HOME/projects"
set -gx SCRIPTS_DIR "$HOME/.local/bin"

# Tool Configs
set -gx RIPGREP_CONFIG_PATH "$XDG_CONFIG_HOME/ripgrep/config"
set -gx STARSHIP_CONFIG "$XDG_CONFIG_HOME/starship.toml"

# === PATH Setup ===
fish_add_path -g "$HOME/bin"
fish_add_path -g "$SCRIPTS_DIR"
fish_add_path -g "$HOME/.spicetify"

# === Homebrew (macOS) ===
if test (uname) = "Darwin"
    if test -f /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -f /usr/local/bin/brew
        eval (/usr/local/bin/brew shellenv)
    end
end

# === Prompt (Starship) ===
if type -q starship
    starship init fish | source
end

# === Local Config Override ===
test -f "$HOME/.config/fish/config.local.fish" && source "$HOME/.config/fish/config.local.fish"

# === Interactive Session Banner ===
if status --is-interactive
    echo "🤖 Fish shell initialized"
end
fish_add_path ~/dotfiles/scripts
