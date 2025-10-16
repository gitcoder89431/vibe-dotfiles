# fzf (Fuzzy Finder) Configuration
# Target: common
# Version: 1.1

# Set the default command for fzf to use fd
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'

# Set preview options for keybindings
set -x FZF_CTRL_T_OPTS "--preview 'bat --color=always {}'"
set -x FZF_ALT_C_OPTS "--preview 'eza --tree --color=always --level=2 {} | head -200'"

# Enable fzf integration via official fish integration
if type -q fzf
    fzf --fish | source
end
