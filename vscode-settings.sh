#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_USER_DIR="$HOME/AppData/Roaming/Code/User"

SETTINGS_FILE="$VSCODE_USER_DIR/settings.json"
SETTINGS_TEMPLATE="$SCRIPT_DIR/vscode-settings.json"

KEYBINDINGS_FILE="$VSCODE_USER_DIR/keybindings.json"
KEYBINDINGS_TEMPLATE="$SCRIPT_DIR/vscode-keybindings.json"

strip_jsonc_comments() {
    sed '/^[[:space:]]*\/\//d'
}

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required but not installed. Install it from https://jqlang.org/" >&2
    exit 1
fi

# --- settings.json (object merge) ---

if [ ! -f "$SETTINGS_TEMPLATE" ]; then
    echo "ERROR: template file not found: $SETTINGS_TEMPLATE" >&2
    exit 1
fi

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Settings file not found, creating: $SETTINGS_FILE"
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    echo '{}' > "$SETTINGS_FILE"
fi

CURRENT=$(cat "$SETTINGS_FILE")
UPDATED="$CURRENT"
set_count=0
skip_count=0

while IFS= read -r key; do
    if echo "$CURRENT" | jq -e --arg k "$key" 'has($k) and .[$k] != null' > /dev/null 2>&1; then
        echo "SKIP: '$key' is already set" >&2
        (( skip_count++ )) || true
    else
        value=$(jq --arg k "$key" '.[$k]' "$SETTINGS_TEMPLATE")
        UPDATED=$(echo "$UPDATED" | jq --arg k "$key" --argjson v "$value" '. + {($k): $v}')
        echo "SET:  '$key'"
        (( set_count++ )) || true
    fi
done < <(jq -r 'keys[]' "$SETTINGS_TEMPLATE" | tr -d '\r')

printf '%s' "$UPDATED" | jq '.' > "$SETTINGS_FILE"
echo ""
echo "Done. Applied $set_count setting(s), skipped $skip_count. Settings file: $SETTINGS_FILE"

# --- keybindings.json (array merge by key+command) ---

if [ ! -f "$KEYBINDINGS_TEMPLATE" ]; then
    echo "ERROR: template file not found: $KEYBINDINGS_TEMPLATE" >&2
    exit 1
fi

if [ ! -f "$KEYBINDINGS_FILE" ]; then
    echo "Keybindings file not found, creating: $KEYBINDINGS_FILE"
    mkdir -p "$(dirname "$KEYBINDINGS_FILE")"
    echo '[]' > "$KEYBINDINGS_FILE"
fi

KB_CURRENT=$(cat "$KEYBINDINGS_FILE" | strip_jsonc_comments)
KB_UPDATED="$KB_CURRENT"
kb_set_count=0
kb_skip_count=0

while IFS= read -r entry; do
    entry_key=$(echo "$entry" | jq -r '.key')
    entry_cmd=$(echo "$entry" | jq -r '.command')
    if echo "$KB_CURRENT" | jq -e --arg k "$entry_key" --arg c "$entry_cmd" \
        'any(.[]; .key == $k and .command == $c)' > /dev/null 2>&1; then
        echo "SKIP: keybinding '$entry_key' -> '$entry_cmd' is already set" >&2
        (( kb_skip_count++ )) || true
    else
        KB_UPDATED=$(echo "$KB_UPDATED" | jq --argjson e "$entry" '. + [$e]')
        echo "SET:  keybinding '$entry_key' -> '$entry_cmd'"
        (( kb_set_count++ )) || true
    fi
done < <(jq -c '.[]' "$KEYBINDINGS_TEMPLATE" | tr -d '\r')

printf '%s' "$KB_UPDATED" | jq '.' > "$KEYBINDINGS_FILE"
echo ""
echo "Done. Applied $kb_set_count keybinding(s), skipped $kb_skip_count. Keybindings file: $KEYBINDINGS_FILE"
