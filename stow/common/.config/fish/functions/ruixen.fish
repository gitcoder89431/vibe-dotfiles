# Ruixen - Natural Language Command Translator
# Usage: ruixen "find files with dog in name"
#        ruixen --navi "docker commands"
#        ruixen --history "git command I used yesterday"
#        ruixen --run "show disk usage"

function ruixen --description "Translate natural language to shell commands"
    # Configuration
    set -l config_dir "$HOME/.config/ruixen"
    set -l translator "$config_dir/translate.py"

    # Parse arguments
    set -l mode "direct"
    set -l auto_run false
    set -l force_navi false
    set -l use_history false
    set -l query ""

    # Parse flags
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -h --help
                echo "Ruixen - Natural Language Command Translator"
                echo ""
                echo "Usage:"
                echo "  ruixen <query>              Translate and preview command"
                echo "  ruixen --run <query>        Translate and execute immediately"
                echo "  ruixen --navi <query>       Search navi cheats interactively"
                echo "  ruixen --history <query>    Search command history"
                echo "  ruixen --explain <query>    Show detailed explanation"
                echo ""
                echo "Examples:"
                echo "  ruixen \"find files with dog in name\""
                echo "  ruixen --run \"show disk usage\""
                echo "  ruixen --navi \"docker logs\""
                return 0

            case -r --run
                set auto_run true

            case -n --navi
                set force_navi true

            case --history
                set use_history true

            case '*'
                set query $query $argv[$i]
        end
        set i (math $i + 1)
    end

    # Join query words
    set query (string join " " $query)

    if test -z "$query"
        echo "Error: No query provided" >&2
        echo "Usage: ruixen <query>" >&2
        return 1
    end

    # Check if translator exists
    if not test -f "$translator"
        echo "Error: Ruixen translator not found at $translator" >&2
        echo "Run: stow to install ruixen configuration" >&2
        return 1
    end

    # Force navi mode
    if test "$force_navi" = true
        navi --query "$query"
        return $status
    end

    # History search mode
    if test "$use_history" = true
        if type -q atuin
            atuin search "$query"
        else
            history search --contains "$query" | fzf
        end
        return $status
    end

    # Call Python translator
    echo "🤖 Translating: $query" >&2
    set -l result (python3 "$translator" $query 2>&1)

    if test $status -ne 0
        echo "Error running translator:" >&2
        echo "$result" >&2

        # Fallback to navi
        echo "" >&2
        echo "💡 Falling back to navi search..." >&2
        navi --query "$query"
        return $status
    end

    # Parse JSON response
    set -l command (echo "$result" | jq -r '.command // empty')
    set -l explanation (echo "$result" | jq -r '.explanation // empty')
    set -l requires_confirmation (echo "$result" | jq -r '.requires_confirmation // false')
    set -l confidence (echo "$result" | jq -r '.confidence // 0')
    set -l is_fallback (echo "$result" | jq -r '.is_fallback // false')
    set -l from_cache (echo "$result" | jq -r '.from_cache // false')
    set -l danger_warning (echo "$result" | jq -r '.danger_warning // false')

    if test -z "$command"
        echo "Error: No command generated" >&2
        echo "💡 Try: ruixen --navi \"$query\"" >&2
        return 1
    end

    # Display result
    echo ""
    if test "$from_cache" = true
        echo "📦 From cache"
    end

    if test "$is_fallback" = true
        echo "⚠️  LLM unavailable, using fallback"
    end

    echo "📝 Command:"
    if type -q bat
        echo "$command" | bat --language bash --style plain --color always
    else
        echo "  $command"
    end

    echo ""
    echo "💡 Explanation: $explanation"
    echo "🎯 Confidence: "(math "round($confidence * 100)")"%"

    if test "$danger_warning" = true
        echo ""
        echo "⚠️  WARNING: This command may be dangerous!"
    end

    # Handle execution
    if test "$auto_run" = true
        if test "$requires_confirmation" = true; or test "$danger_warning" = true
            echo ""
            read -P "⚠️  This command requires confirmation. Run it? [y/N] " -l confirm
            if test "$confirm" != "y"; and test "$confirm" != "Y"
                echo "❌ Cancelled"
                return 0
            end
        end

        echo ""
        echo "▶️  Executing..."
        eval "$command"
        return $status
    else
        # Preview mode - offer to run
        echo ""
        read -P "Run this command? [y/N/c=copy] " -l action

        switch $action
            case y Y
                echo "▶️  Executing..."
                eval "$command"
                return $status

            case c C
                if type -q pbcopy
                    echo "$command" | pbcopy
                    echo "📋 Copied to clipboard"
                else if type -q xclip
                    echo "$command" | xclip -selection clipboard
                    echo "📋 Copied to clipboard"
                else
                    echo "❌ Clipboard tool not found"
                end
                return 0

            case '*'
                echo "💡 Command not executed. Copy it manually if needed:"
                echo "  $command"
                return 0
        end
    end
end
