# Fish Aliases and Functions
# Target: common
# Version: 1.1

# === Modern Replacements ===
alias ls="eza --icons"
alias la="eza -a --icons"
alias ll="eza -l --icons --git"
alias llt="eza -T --icons" # tree view
alias cat="bat --paging=never"
alias grep="rg"
alias find="fd"
alias du="dust"
alias df="duf"
alias ps="procs"

# === Navigation ===
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias c="clear"
alias h="history"

# === Git Aliases ===
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias gdca="git diff --cached"
alias gl="git pull"
alias gp="git push"
alias gst="git status"
alias glog="git log --oneline --decorate --color --graph"
alias gsta="git stash"
alias gstp="git stash pop"
alias gb="git branch"

# === Docker Aliases ===
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dimg="docker images"
alias dx="docker exec -it"
alias dlog="docker logs -f"

# === Tools ===
alias lg="lazygit"
alias ld="lazydocker"
alias br="broot"
alias preview="glow"
alias vim="nvim"

# === Helper Functions ===

# FzfEdit - Fuzzy find and edit file
function FzfEdit
    fd . --type f | fzf --preview 'bat --color=always {}' | xargs -I {} $EDITOR "{}"
end

# fe - Fuzzy file edit (simpler version)
function fe
    set -l file (fzf --preview 'bat --color=always {}')
    test -n "$file" && $EDITOR "$file"
end

# rgs - Ripgrep search and edit
function rgs
    if test (count $argv) -lt 1
        echo "Usage: rgs <pattern>"
        return 1
    end
    set -l pattern $argv[1]
    set -l file (rg --files-with-matches --no-messages "$pattern" | \
                 fzf --preview "rg --color=always --context=3 '$pattern' {}")
    test -n "$file" && $EDITOR "$file"
end

# mkcd - Make directory and cd into it
function mkcd
    test (count $argv) -eq 0 && echo "Usage: mkcd <dirname>" && return 1
    mkdir -p "$argv[1]" && cd "$argv[1]"
end

# gcl - Git clone and cd
function gcl
    test (count $argv) -eq 0 && echo "Usage: gcl <repo-url>" && return 1
    git clone "$argv[1]"
    set -l dir (basename "$argv[1]" .git)
    test -d "$dir" && cd "$dir"
end

# denter - Docker exec interactive (fuzzy select container)
function denter
    set -l container (docker ps --format '{{.Names}}' | fzf)
    test -n "$container" && docker exec -it "$container" /bin/bash
end

# note - Quick note taking
function note
    if test (count $argv) -eq 0
        echo "Usage: note <text>"
        echo "Example: note 'Fixed the bug in user auth'"
    else
        echo "[(date '+%Y-%m-%d %H:%M')] $argv" >> ~/notes/notes.txt
        echo "Note saved!"
    end
end
