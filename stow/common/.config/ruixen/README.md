# Ruixen 🤖

**Natural language → shell commands. 100% local. No API keys.**

## What It Does

Type what you want in plain English, get the actual command:

```bash
ruixen "find files with dog in name"
→ fd dog

ruixen "show disk usage"
→ duf

ruixen "search for TODO in python files"
→ rg 'TODO' --type py
```

## Install

```bash
# 1. Setup
~/.config/ruixen/setup.sh

# 2. Install Ollama (local LLM)
brew install ollama
brew services start ollama

# 3. Pull a model (choose one)
ollama pull gemma3:1b       # Good balance (815 MB)
ollama pull gemma3:270m     # Tiny and fast! (291 MB)
```

Done. No API keys needed.

## Usage

```bash
# Basic: preview command
ruixen "your query here"

# Execute immediately
ruixen --run "show system info"

# Search your cheats
ruixen --navi "docker"

# Search history
ruixen --history "git command"
```

## Examples

```bash
# Files
ruixen "find json files larger than 1MB"
ruixen "files changed today"

# Git
ruixen "undo last commit"
ruixen "stash my changes"

# Docker
ruixen "stop all containers"
ruixen "show logs for web service"

# System
ruixen "what's using memory"
ruixen "network connections on port 3000"
```

## Privacy

Everything runs on your machine:
- ✅ Local LLM processing (Ollama)
- ✅ No cloud APIs
- ✅ No API keys
- ✅ Your data stays yours

Your command history might contain passwords, API keys, secrets. That's why ruixen is local-only.

## Troubleshooting

**"Ollama server not responding"**
```bash
ollama serve
# or
brew services start ollama
```

**Ollama down?** Ruixen falls back to navi search automatically.

**Clear cache:**
```bash
rm -rf ~/.config/ruixen/cache/*
```

## Configuration

Edit `~/.config/ruixen/config.yaml`:

```yaml
# Use different model
llm:
  model: gemma3:1b     # or gemma3:270m (tiny!)

# Adjust safety
safety:
  blacklisted_binaries:
    - rm
    - your-dangerous-command
```

That's it. Simple tool, does one thing well.