# Vibe Dotfiles

A shareable dotfiles setup for a modern macOS workflow, managed with `stow`.

## What's Inside?

This setup includes configurations for:

- **Shell:** Fish (with aliases, `fzf`, `zoxide`)
- **Prompt:** Starship (Catppuccin Mocha theme)
- **Terminal:** WezTerm (Catppuccin Mocha theme)
- **Editor:** Zed (Catppuccin Blurred Mocha theme)
- **Launcher:** Raycast, Zen Browser
- **Terminal Tools:**
  - `broot`: A new way to see and navigate directory trees
  - `navi`: An interactive cheatsheet tool
  - `lazygit`: A terminal UI for git
  - `lazydocker`: A terminal UI for Docker
  - `fastfetch`: A fast system information tool
  - `htop`: An interactive process viewer
  - `copilot`: Copilot CLI, a terminal-based AI assistant

## Screenshots

Here are some screenshots of the setup in action:

![Screenshot 1](./screenshot_01.png)
![Screenshot 2](./screenshot_02.png)

> For more details and configuration, see the relevant files in the `stow/` directory.

## Quick Install

An installer script is included to automate the entire setup.

**Warning:** The script will install Homebrew packages and modify your default shell. Please review the `install.sh` script before running.

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/public-dotfiles.git ~/public-dotfiles
cd ~/public-dotfiles

# Run the installer
./install.sh
```

**Note:** You will need to replace the git URL with your own once you've pushed this repository to GitHub.

## Manual Installation

If you prefer to install things step-by-step:

1.  **Clone the repository:**

    ```bash
    git clone <your-repo-url> ~/public-dotfiles
    ```

2.  **Install the tools:**
    All required tools can be installed with Homebrew. A `navi` cheatsheet is included with the necessary command.

    ```bash
    # Install navi first
    brew install navi

    # Use navi to view and run the install command
    navi
    ```

3.  **Stow the configurations:**
    This will create symlinks from this repository to the correct locations in your home directory.
    ```bash
    cd ~/public-dotfiles
    stow --dir=stow --target=$HOME --restow common mac
    ```
