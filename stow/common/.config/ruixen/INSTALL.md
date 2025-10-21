# Ruixen - Standalone Installation

Want to use ruixen without the full vibe-dotfiles setup? Here's how.

## What You Need

- **macOS or Linux**
- **Fish shell** (or bash/zsh with modifications)
- **Python 3** (system python is fine)
- **Ollama** (local LLM server)

## Quick Install

```bash
# 1. Create config directory
mkdir -p ~/.config/ruixen/prompts
mkdir -p ~/.config/fish/functions

# 2. Download ruixen files
cd ~/.config/ruixen
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/vibe-dotfiles/main/stow/common/.config/ruixen/config.yaml
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/vibe-dotfiles/main/stow/common/.config/ruixen/translate.py
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/vibe-dotfiles/main/stow/common/.config/ruixen/setup.sh
curl -o prompts/system.txt https://raw.githubusercontent.com/YOUR_USERNAME/vibe-dotfiles/main/stow/common/.config/ruixen/prompts/system.txt

# 3. Download Fish function
cd ~/.config/fish/functions
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/vibe-dotfiles/main/stow/common/.config/fish/functions/ruixen.fish

# 4. Make executable
chmod +x ~/.config/ruixen/translate.py
chmod +x ~/.config/ruixen/setup.sh

# 5. Run setup
~/.config/ruixen/setup.sh

# 6. Install Ollama
brew install ollama
brew services start ollama
ollama pull qwen2.5:0.5b

# 7. Restart Fish
exec fish
```

## Manual Install (Copy Files)

If you've cloned vibe-dotfiles locally:

```bash
# From vibe-dotfiles directory
cp -r stow/common/.config/ruixen ~/.config/
cp stow/common/.config/fish/functions/ruixen.fish ~/.config/fish/functions/

# Make executable
chmod +x ~/.config/ruixen/translate.py
chmod +x ~/.config/ruixen/setup.sh

# Run setup
~/.config/ruixen/setup.sh
```

## For Bash/Zsh Users

Ruixen uses a Fish function, but you can adapt it:

### Bash/Zsh Wrapper

Create `~/.local/bin/ruixen`:

```bash
#!/usr/bin/env bash
# Ruixen wrapper for bash/zsh

query="$*"
translator="$HOME/.config/ruixen/translate.py"

if [ -z "$query" ]; then
    echo "Usage: ruixen <natural language query>"
    exit 1
fi

# Call translator
result=$(python3 "$translator" "$query" 2>&1)

# Parse JSON (requires jq)
command=$(echo "$result" | jq -r '.command // empty')
explanation=$(echo "$result" | jq -r '.explanation // empty')
requires_confirmation=$(echo "$result" | jq -r '.requires_confirmation // false')

if [ -z "$command" ]; then
    echo "Error: No command generated"
    exit 1
fi

# Display
echo ""
echo "Command: $command"
echo "Explanation: $explanation"
echo ""

# Ask to run
read -p "Run this command? [y/N] " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    eval "$command"
fi
```

Make it executable:
```bash
chmod +x ~/.local/bin/ruixen
```

## Dependencies

### Required
- **Python 3** - Comes with macOS/most Linux
- **Ollama** - `brew install ollama` or from [ollama.ai](https://ollama.ai)
- **jq** - `brew install jq` (for JSON parsing)

### Optional (Enhanced Experience)
- **navi** - `brew install navi` (fallback search mode)
- **bat** - `brew install bat` (syntax highlighting)
- **atuin** - `brew install atuin` (history search mode)
- **fzf** - `brew install fzf` (fuzzy finding)

## Recommended Ollama Models

Choose one based on your needs:

```bash
# Fastest, smallest (recommended)
ollama pull qwen2.5:0.5b

# More capable
ollama pull gemma2:2b

# Balanced
ollama pull llama3.2:1b

# If you already have gemma3:1b (like in vibe-dotfiles)
# Edit ~/.config/ruixen/config.yaml and change model to gemma3:1b
```

## Configuration

Edit `~/.config/ruixen/config.yaml`:

```yaml
# Use your installed model
llm:
  model: qwen2.5:0.5b  # or gemma2:2b, llama3.2:1b, gemma3:1b

# Adjust safety (optional)
safety:
  blacklisted_binaries:
    - rm
    - dd
    - your-dangerous-command
```

## Verify Installation

```bash
# Test translator directly
python3 ~/.config/ruixen/translate.py "find files with dog in name"

# Should return JSON with command: fd dog

# Test full command (Fish)
ruixen "show disk usage"

# Test fallback (stop Ollama first)
brew services stop ollama
ruixen "docker logs"  # Should fallback to navi
```

## Troubleshooting

**"ruixen: command not found"**
- Fish: Restart shell with `exec fish`
- Bash/Zsh: Add `~/.local/bin` to PATH

**"Ollama server not responding"**
```bash
brew services start ollama
# or
ollama serve
```

**"Model not found"**
```bash
ollama list  # Check installed models
ollama pull qwen2.5:0.5b  # Pull recommended model
```

**Function not loading (Fish)**
```bash
# Reload functions
source ~/.config/fish/functions/ruixen.fish
# or restart
exec fish
```

## Uninstall

```bash
# Remove files
rm -rf ~/.config/ruixen
rm ~/.config/fish/functions/ruixen.fish

# Stop Ollama (optional)
brew services stop ollama
```

## Integration with Your Dotfiles

Want to add ruixen to your own dotfiles?

1. Copy the `ruixen/` directory to your dotfiles
2. Copy `ruixen.fish` to your fish functions
3. Add to your README:
   ```
   ## Ruixen
   Natural language command translator (local LLM, privacy-first)
   - Install: `~/.config/ruixen/setup.sh`
   - Usage: `ruixen "find files with dog"`
   ```

## What Ruixen Works Best With

While standalone, ruixen is enhanced by:
- **navi** - Curated command cheats (fallback mode)
- **atuin** - Smart history search
- **fd, rg, eza, bat** - Modern CLI tools it suggests
- **lazygit, lazydocker** - TUI tools it knows about

Consider installing these for the full experience!

## License

MIT - Do whatever you want with it!

## Credits

Built as part of [vibe-dotfiles](https://github.com/YOUR_USERNAME/vibe-dotfiles).
Inspired by modern CLI workflows and privacy-first design.