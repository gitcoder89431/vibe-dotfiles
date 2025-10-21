#!/usr/bin/env bash
# Ruixen Demo Script
# Shows off the three modes of ruixen

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}🤖 Ruixen Demo - Natural Language Command Translator${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if ruixen is available
if ! type ruixen &>/dev/null; then
    echo -e "${YELLOW}⚠ Ruixen not available yet. Run 'stow' first!${NC}"
    echo "For now, let's test the underlying translator..."
    echo ""
fi

TRANSLATOR="$HOME/.config/ruixen/translate.py"
if [ ! -f "$TRANSLATOR" ]; then
    echo -e "${YELLOW}⚠ Translator not found. Make sure you've run:${NC}"
    echo "  cd ~/vibe-dotfiles"
    echo "  stow --dir=stow --target=\$HOME --restow common"
    exit 1
fi

echo -e "${BLUE}═══ Mode 1: Direct Translation (Smart Mode) ═══${NC}"
echo ""
echo -e "${GREEN}Example:${NC} ruixen \"find files with dog in name\""
echo "Expected: fd dog"
echo ""
echo "Running translator..."
python3 "$TRANSLATOR" "find files with dog in name" 2>&1 | grep -A 10 "^{"
echo ""

sleep 2

echo ""
echo -e "${BLUE}═══ Mode 2: Navi Integration ═══${NC}"
echo ""
echo -e "${GREEN}Example:${NC} ruixen --navi \"docker logs\""
echo "Expected: Opens navi with docker commands pre-filtered"
echo ""
echo "This would run: navi --query 'docker logs'"
echo "(Opening navi interactively...)"
echo ""

sleep 2

echo ""
echo -e "${BLUE}═══ Mode 3: History Search ═══${NC}"
echo ""
echo -e "${GREEN}Example:${NC} ruixen --history \"git command\""
echo "Expected: Searches Atuin/history for git commands"
echo ""
echo "This would run: atuin search 'git command'"
echo "(Searching your command history...)"
echo ""

sleep 2

echo ""
echo -e "${BLUE}═══ More Examples ═══${NC}"
echo ""

examples=(
    "show disk usage"
    "list docker containers"
    "search for TODO in python files"
    "show me files changed today"
    "what's using memory"
)

for example in "${examples[@]}"; do
    echo -e "${CYAN}→${NC} ruixen \"$example\""
    result=$(python3 "$TRANSLATOR" "$example" 2>/dev/null | jq -r '.command // empty')
    if [ -n "$result" ]; then
        echo -e "  ${GREEN}→${NC} $result"
    else
        echo -e "  ${YELLOW}(LLM unavailable - would fallback to navi)${NC}"
    fi
    echo ""
    sleep 1
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✨ Ruixen Features:${NC}"
echo ""
echo "  🧠 Smart translation using local LLM (Ollama)"
echo "  🎯 Context-aware (pwd, git repo, project type)"
echo "  🛡️ Safety checks for dangerous commands"
echo "  📦 Fast caching (1hr TTL)"
echo "  🔄 Graceful fallback to navi when LLM unavailable"
echo "  🎨 Beautiful output with syntax highlighting"
echo ""
echo -e "${CYAN}Try it yourself:${NC}"
echo "  ruixen \"your natural language query here\""
echo "  ruixen --help"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
