#!/usr/bin/env bash
# Ruixen Setup Script
# 100% LOCAL & PRIVATE - No API keys needed
# Installs dependencies and configures ruixen

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖🔒 Setting up Ruixen - Privacy-First Command Translator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ 100% LOCAL - All processing on your machine"
echo "✅ NO API KEYS - No OpenAI, no Anthropic, no cloud"
echo "✅ PRIVATE - Your commands and history stay yours"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Python 3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is required but not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Python 3 found: $(python3 --version)"

# Try to install PyYAML
echo ""
echo "Installing Python dependencies..."

if python3 -c "import yaml" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} PyYAML already installed"
else
    echo "Attempting to install PyYAML..."

    # Try pip install --user first
    if python3 -m pip install --user pyyaml 2>/dev/null; then
        echo -e "${GREEN}✓${NC} PyYAML installed via pip --user"
    # Try with break-system-packages flag (for newer systems)
    elif python3 -m pip install --break-system-packages pyyaml 2>/dev/null; then
        echo -e "${GREEN}✓${NC} PyYAML installed via pip --break-system-packages"
    # Try brew if on macOS
    elif command -v brew &> /dev/null && brew install python-yq 2>/dev/null; then
        echo -e "${GREEN}✓${NC} PyYAML installed via brew"
    else
        echo -e "${YELLOW}⚠${NC} Could not install PyYAML automatically"
        echo "  Ruixen will work with default config (no YAML support)"
        echo "  To enable YAML config, install manually:"
        echo "    python3 -m pip install --user pyyaml"
    fi
fi

# Check Ollama (required for privacy-first operation)
echo ""
echo "Checking Ollama (local LLM server)..."
if command -v ollama &> /dev/null; then
    echo -e "${GREEN}✓${NC} Ollama found: $(which ollama)"

    # Check if ollama is running
    if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Ollama server is running"

        # Check for recommended models
        echo ""
        echo "Checking for recommended models..."
        MODELS=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' || echo "")

        if echo "$MODELS" | grep -q "qwen2.5:0.5b"; then
            echo -e "${GREEN}✓${NC} qwen2.5:0.5b (recommended) is installed"
        elif echo "$MODELS" | grep -q "gemma2:2b"; then
            echo -e "${GREEN}✓${NC} gemma2:2b is installed"
        elif echo "$MODELS" | grep -q "llama3.2:1b"; then
            echo -e "${GREEN}✓${NC} llama3.2:1b is installed"
        else
            echo -e "${YELLOW}⚠${NC} No recommended model found"
            echo ""
            echo "  Install a model (choose one):"
            echo "    ollama pull qwen2.5:0.5b   # Fastest, smallest (recommended)"
            echo "    ollama pull gemma2:2b      # Good balance"
            echo "    ollama pull llama3.2:1b    # Also great"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Ollama is installed but not running"
        echo "  Start it with: ollama serve"
        echo "  Or run as service: brew services start ollama"
    fi
else
    echo -e "${YELLOW}⚠${NC} Ollama not found (REQUIRED for privacy-first operation)"
    echo ""
    echo "  Ollama is a local LLM server that runs on your machine."
    echo "  No data is sent to external APIs."
    echo ""
    echo "  Install with: brew install ollama"
    echo "  Then start it: ollama serve"
    echo "  Or as service: brew services start ollama"
fi

# Check for optional tools
echo ""
echo "Checking optional dependencies..."

if command -v jq &> /dev/null; then
    echo -e "${GREEN}✓${NC} jq (JSON parser)"
else
    echo -e "${YELLOW}⚠${NC} jq not found (recommended: brew install jq)"
fi

if command -v bat &> /dev/null; then
    echo -e "${GREEN}✓${NC} bat (syntax highlighting)"
else
    echo -e "${YELLOW}⚠${NC} bat not found (recommended for pretty output)"
fi

if command -v navi &> /dev/null; then
    echo -e "${GREEN}✓${NC} navi (fallback search)"
else
    echo -e "${YELLOW}⚠${NC} navi not found (fallback won't work)"
fi

# Make translator executable
echo ""
TRANSLATOR="$HOME/.config/ruixen/translate.py"
if [ -f "$TRANSLATOR" ]; then
    chmod +x "$TRANSLATOR"
    echo -e "${GREEN}✓${NC} Made translator executable"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✨ Setup complete!${NC}"
echo ""
echo -e "${CYAN}🔒 Privacy guarantee:${NC}"
echo "  • All LLM processing happens locally (Ollama)"
echo "  • No API keys needed (cloud support removed)"
echo "  • Your commands, history, and data never leave your machine"
echo "  • No telemetry, no tracking, no external calls"
echo ""
echo "Try ruixen:"
echo "  ruixen \"find files with dog in name\""
echo "  ruixen \"show disk usage\""
echo "  ruixen --help"
echo ""
echo "Configuration: ~/.config/ruixen/config.yaml"
echo "Documentation: ~/.config/ruixen/README.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
