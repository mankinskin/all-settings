#!/usr/bin/env bash
# Sync the repo's VSCode settings template (vscode-settings.json) with the
# currently active VSCode user settings (settings.json).
#
# This is the reverse of vscode-settings.sh: instead of applying the template
# to the live settings, it pulls live changes back into the template so they
# can be committed.
#
# For every difference (added, modified, or removed key) the diff is printed
# and confirmation is requested, unless -y/--yes is passed to accept all.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_USER_DIR="$HOME/AppData/Roaming/Code/User"

SETTINGS_FILE="$VSCODE_USER_DIR/settings.json"
SETTINGS_TEMPLATE="$SCRIPT_DIR/vscode-settings.json"

ASSUME_YES=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [-y|--yes] [-h|--help]

Sync vscode-settings.json (repo template) with the active VSCode settings.json.

Options:
  -y, --yes    Apply every change without asking for confirmation.
  -h, --help   Show this help and exit.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes) ASSUME_YES=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "ERROR: unknown argument: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

strip_jsonc_comments() {
    sed '/^[[:space:]]*\/\//d'
}

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required but not installed. Install it from https://jqlang.org/" >&2
    exit 1
fi

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "ERROR: active settings file not found: $SETTINGS_FILE" >&2
    exit 1
fi

if [ ! -f "$SETTINGS_TEMPLATE" ]; then
    echo "Template not found, creating: $SETTINGS_TEMPLATE"
    echo '{}' > "$SETTINGS_TEMPLATE"
fi

# The install script resolves these placeholder paths to the real $HOME when
# writing to the active settings. Reverse that here so a synced value matches
# the placeholder form already stored in the template (avoids false diffs).
unresolve_value() {
    local key="$1"
    local value_json="$2"

    if [[ "$key" == vscode-neovim.neovimInitVimPaths.* ]] && echo "$value_json" | jq -e 'type == "string"' >/dev/null 2>&1; then
        local value
        value=$(echo "$value_json" | jq -r '.')
        if [[ "$key" == "vscode-neovim.neovimInitVimPaths.win32" ]]; then
            # VSCode stores Windows paths in drive-letter form (C:/Users/...),
            # while $HOME under Git Bash is POSIX form (/c/Users/...). Convert
            # the POSIX home to the Windows form so both match the placeholder.
            local win_home="$HOME"
            if [[ "$HOME" =~ ^/([a-zA-Z])/(.*)$ ]]; then
                win_home="${BASH_REMATCH[1]^^}:/${BASH_REMATCH[2]}"
            fi
            value="${value//$win_home/'${env:USERPROFILE}'}"
            value="${value//$HOME/'${env:USERPROFILE}'}"
        else
            value="${value//$HOME/'${env:HOME}'}"
        fi
        printf '%s' "$value" | jq -R '.'
    else
        printf '%s' "$value_json"
    fi
}

prompt_confirm() {
    [ "$ASSUME_YES" -eq 1 ] && return 0
    local reply
    read -r -p "Apply this change? [y/N] " reply </dev/tty
    [[ "$reply" =~ ^[Yy]$ ]]
}

show_value() {
    # Pretty-print a JSON value, indenting each line for readability.
    echo "$1" | jq '.' | sed 's/^/    /'
}

ACTIVE=$(strip_jsonc_comments < "$SETTINGS_FILE")
TEMPLATE=$(cat "$SETTINGS_TEMPLATE")
UPDATED="$TEMPLATE"

add_count=0
mod_count=0
del_count=0
skip_count=0

# Union of all keys from both files.
ALL_KEYS=$(jq -n --argjson a "$ACTIVE" --argjson t "$TEMPLATE" \
    '($a | keys) + ($t | keys) | unique | .[]' -r | tr -d '\r')

while IFS= read -r key; do
    [ -z "$key" ] && continue

    in_active=$(echo "$ACTIVE" | jq -e --arg k "$key" 'has($k)' >/dev/null 2>&1 && echo 1 || echo 0)
    in_template=$(echo "$TEMPLATE" | jq -e --arg k "$key" 'has($k)' >/dev/null 2>&1 && echo 1 || echo 0)

    if [ "$in_active" -eq 1 ]; then
        active_value=$(echo "$ACTIVE" | jq -c --arg k "$key" '.[$k]')
        active_value=$(unresolve_value "$key" "$active_value")
    fi
    if [ "$in_template" -eq 1 ]; then
        template_value=$(echo "$TEMPLATE" | jq -c --arg k "$key" '.[$k]')
    fi

    if [ "$in_active" -eq 1 ] && [ "$in_template" -eq 0 ]; then
        echo ""
        echo "ADD: '$key'"
        echo "  + new value:"
        show_value "$active_value"
        if prompt_confirm; then
            UPDATED=$(echo "$UPDATED" | jq --arg k "$key" --argjson v "$active_value" '. + {($k): $v}')
            (( add_count++ )) || true
        else
            (( skip_count++ )) || true
        fi

    elif [ "$in_active" -eq 1 ] && [ "$in_template" -eq 1 ]; then
        if [ "$active_value" == "$template_value" ]; then
            continue
        fi
        echo ""
        echo "MODIFY: '$key'"
        echo "  - template value:"
        show_value "$template_value"
        echo "  + active value:"
        show_value "$active_value"
        if prompt_confirm; then
            UPDATED=$(echo "$UPDATED" | jq --arg k "$key" --argjson v "$active_value" '. + {($k): $v}')
            (( mod_count++ )) || true
        else
            (( skip_count++ )) || true
        fi

    elif [ "$in_active" -eq 0 ] && [ "$in_template" -eq 1 ]; then
        echo ""
        echo "REMOVE: '$key' (present in template, absent from active settings)"
        echo "  - template value:"
        show_value "$template_value"
        if prompt_confirm; then
            UPDATED=$(echo "$UPDATED" | jq --arg k "$key" 'del(.[$k])')
            (( del_count++ )) || true
        else
            (( skip_count++ )) || true
        fi
    fi
done < <(echo "$ALL_KEYS")

printf '%s' "$UPDATED" | jq '.' > "$SETTINGS_TEMPLATE"

echo ""
echo "Done. Added $add_count, modified $mod_count, removed $del_count, skipped $skip_count."
echo "Template file: $SETTINGS_TEMPLATE"
