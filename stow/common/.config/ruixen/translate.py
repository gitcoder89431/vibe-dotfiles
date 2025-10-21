#!/usr/bin/env python3
"""
Ruixen - Natural Language Command Translator
100% LOCAL & PRIVATE - No data leaves your machine
Powered by Ollama (local LLM)
"""

import json
import os
import sys
import subprocess
from pathlib import Path
from typing import Dict, Optional
import hashlib
import time
import urllib.request
import urllib.error

# Try to import yaml, fallback to JSON if not available
try:
    import yaml

    HAS_YAML = True
except ImportError:
    HAS_YAML = False

# Configuration paths
CONFIG_DIR = Path.home() / ".config" / "ruixen"
CONFIG_FILE = CONFIG_DIR / "config.yaml"
CACHE_DIR = CONFIG_DIR / "cache"
PROMPT_FILE = CONFIG_DIR / "prompts" / "system.txt"


class RuixenTranslator:
    """Local-only command translator using Ollama"""

    def __init__(self):
        self.config = self.load_config()
        self.system_prompt = self.load_system_prompt()
        CACHE_DIR.mkdir(parents=True, exist_ok=True)

    def load_config(self) -> Dict:
        """Load configuration from YAML file"""
        if not CONFIG_FILE.exists():
            return self.get_default_config()

        if not HAS_YAML:
            return self.get_default_config()

        try:
            with open(CONFIG_FILE, "r") as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"Warning: Could not load config: {e}", file=sys.stderr)
            return self.get_default_config()

    def get_default_config(self) -> Dict:
        """Return default configuration (local-only)"""
        return {
            "llm": {
                "endpoint": "http://localhost:11434",
                "model": "qwen2.5:0.5b",
                "timeout": 10,
                "temperature": 0.1,
            },
            "execution": {"preview_before_run": True, "timeout": 30},
            "safety": {
                "blacklisted_binaries": ["rm", "dd", "mkfs", "fdisk", "sudo rm"],
                "dangerous_patterns": ["rm -rf", "dd if=", "> /dev/"],
            },
            "context": {
                "include_pwd": True,
                "include_git_status": True,
                "include_project_type": True,
            },
            "cache": {"enabled": True, "ttl": 3600, "max_size": 100},
            "fallback": {"use_navi_search": True, "suggest_alternatives": True},
        }

    def load_system_prompt(self) -> str:
        """Load system prompt from file"""
        if not PROMPT_FILE.exists():
            return "Translate natural language to shell commands. Return only JSON."

        with open(PROMPT_FILE, "r") as f:
            return f.read()

    def get_context(self) -> Dict:
        """Gather shell context (pwd, git status, etc.)"""
        context = {
            "pwd": os.getcwd(),
            "shell": os.environ.get("SHELL", "unknown"),
            "os": sys.platform,
        }

        # Check if in git repo
        if self.config.get("context", {}).get("include_git_status", True):
            try:
                result = subprocess.run(
                    ["git", "rev-parse", "--is-inside-work-tree"],
                    capture_output=True,
                    text=True,
                    timeout=2,
                )
                context["in_git_repo"] = result.returncode == 0

                if context["in_git_repo"]:
                    branch = subprocess.run(
                        ["git", "branch", "--show-current"],
                        capture_output=True,
                        text=True,
                        timeout=2,
                    )
                    context["git_branch"] = branch.stdout.strip()
            except:
                context["in_git_repo"] = False

        # Check for common project files
        if self.config.get("context", {}).get("include_project_type", True):
            cwd = Path.cwd()
            context["has_dockerfile"] = (cwd / "Dockerfile").exists()
            context["has_docker_compose"] = (cwd / "docker-compose.yml").exists() or (
                cwd / "docker-compose.yaml"
            ).exists()
            context["has_package_json"] = (cwd / "package.json").exists()
            context["has_requirements_txt"] = (cwd / "requirements.txt").exists()
            context["has_cargo_toml"] = (cwd / "Cargo.toml").exists()
            context["has_go_mod"] = (cwd / "go.mod").exists()

        return context

    def get_cache_key(self, query: str, context: Dict) -> str:
        """Generate cache key from query and context"""
        # Only use pwd and git status for cache key to avoid over-caching
        cache_str = (
            f"{query}:{context.get('pwd', '')}:{context.get('in_git_repo', False)}"
        )
        return hashlib.md5(cache_str.encode()).hexdigest()

    def get_cached_response(self, cache_key: str) -> Optional[Dict]:
        """Get cached LLM response if valid"""
        if not self.config.get("cache", {}).get("enabled", True):
            return None

        cache_file = CACHE_DIR / f"{cache_key}.json"
        if not cache_file.exists():
            return None

        # Check TTL
        ttl = self.config.get("cache", {}).get("ttl", 3600)
        if time.time() - cache_file.stat().st_mtime > ttl:
            cache_file.unlink()
            return None

        try:
            with open(cache_file, "r") as f:
                return json.load(f)
        except:
            return None

    def save_to_cache(self, cache_key: str, response: Dict):
        """Save LLM response to cache"""
        if not self.config.get("cache", {}).get("enabled", True):
            return

        cache_file = CACHE_DIR / f"{cache_key}.json"
        try:
            with open(cache_file, "w") as f:
                json.dump(response, f)
        except Exception as e:
            print(f"Warning: Could not save to cache: {e}", file=sys.stderr)

    def call_ollama(self, query: str, context: Dict) -> Optional[Dict]:
        """Call Ollama API to translate query (local only)"""
        endpoint = self.config["llm"].get("endpoint", "http://localhost:11434")
        model = self.config["llm"].get("model", "qwen2.5:0.5b")
        timeout = self.config["llm"].get("timeout", 10)
        temperature = self.config["llm"].get("temperature", 0.1)

        # Build prompt with context
        context_str = f"\nContext: pwd={context['pwd']}"
        if context.get("in_git_repo"):
            context_str += f", git_branch={context.get('git_branch', 'unknown')}"
        if context.get("has_dockerfile"):
            context_str += ", has_dockerfile=true"
        if context.get("has_docker_compose"):
            context_str += ", has_docker_compose=true"
        if context.get("has_package_json"):
            context_str += ", has_package_json=true"

        user_prompt = f"{context_str}\n\nUser request: {query}"

        payload = {
            "model": model,
            "prompt": f"{self.system_prompt}\n\n{user_prompt}",
            "stream": False,
            "format": "json",
            "options": {
                "temperature": temperature,
                "num_predict": 150,
            },
        }

        try:
            req = urllib.request.Request(
                f"{endpoint}/api/generate",
                data=json.dumps(payload).encode("utf-8"),
                headers={"Content-Type": "application/json"},
            )

            with urllib.request.urlopen(req, timeout=timeout) as response:
                result = json.loads(response.read().decode("utf-8"))

                # Parse the LLM response
                llm_response = result.get("response", "{}")
                try:
                    return json.loads(llm_response)
                except json.JSONDecodeError:
                    # Try to extract JSON from markdown code blocks
                    if "```json" in llm_response:
                        json_str = llm_response.split("```json")[1].split("```")[0]
                        return json.loads(json_str.strip())
                    elif "```" in llm_response:
                        json_str = llm_response.split("```")[1].split("```")[0]
                        return json.loads(json_str.strip())
                    else:
                        raise

        except urllib.error.URLError as e:
            if self.config.get("fallback", {}).get("verbose_errors", True):
                print(
                    f"Error: Ollama server not responding. Is it running?",
                    file=sys.stderr,
                )
                print(f"Try: ollama serve", file=sys.stderr)
                print(
                    f"Or: brew services start ollama (to run as background service)",
                    file=sys.stderr,
                )
            return None
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON response from LLM", file=sys.stderr)
            print(f"Response was: {llm_response[:200]}", file=sys.stderr)
            return None
        except Exception as e:
            print(f"Error calling Ollama: {e}", file=sys.stderr)
            return None

    def fallback_to_navi(self, query: str) -> Dict:
        """Fallback to navi search when LLM unavailable"""
        return {
            "command": f"navi --query '{query}'",
            "explanation": f"LLM unavailable, searching navi for: {query}",
            "navi_query": query,
            "requires_confirmation": False,
            "confidence": 0.5,
            "is_fallback": True,
        }

    def is_dangerous_command(self, command: str) -> bool:
        """Check if command is dangerous"""
        blacklist = self.config.get("safety", {}).get("blacklisted_binaries", [])
        patterns = self.config.get("safety", {}).get("dangerous_patterns", [])

        # Check blacklisted binaries
        for binary in blacklist:
            if command.strip().startswith(binary) or f" {binary}" in command:
                return True

        # Check dangerous patterns
        for pattern in patterns:
            if pattern in command:
                return True

        return False

    def translate(self, query: str) -> Dict:
        """Main translation function (local only)"""
        context = self.get_context()
        cache_key = self.get_cache_key(query, context)

        # Try cache first
        cached = self.get_cached_response(cache_key)
        if cached:
            cached["from_cache"] = True
            return cached

        # Call local Ollama
        response = self.call_ollama(query, context)

        # Fallback if LLM fails
        if not response:
            if self.config.get("fallback", {}).get("use_navi_search", True):
                return self.fallback_to_navi(query)
            else:
                return {
                    "error": "Ollama unavailable and fallback disabled",
                    "command": None,
                }

        # Validate response
        if not response.get("command"):
            return self.fallback_to_navi(query)

        # Safety check
        if self.is_dangerous_command(response["command"]):
            response["requires_confirmation"] = True
            response["danger_warning"] = True

        # Save to cache
        self.save_to_cache(cache_key, response)

        return response


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: translate.py <natural language query>", file=sys.stderr)
        print("\nRuixen: 100% LOCAL & PRIVATE command translator", file=sys.stderr)
        print("No data leaves your machine. Powered by Ollama.", file=sys.stderr)
        sys.exit(1)

    query = " ".join(sys.argv[1:])
    translator = RuixenTranslator()
    result = translator.translate(query)

    # Output as JSON for fish function to parse
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
