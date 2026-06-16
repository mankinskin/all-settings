#!/usr/bin/env bash
set -euo pipefail

SETTINGS_FILE="$HOME/AppData/Roaming/Code/User/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/vscode-settings.json"

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required but not installed. Install it from https://jqlang.org/" >&2
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "ERROR: template file not found: $TEMPLATE_FILE" >&2
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
        value=$(jq --arg k "$key" '.[$k]' "$TEMPLATE_FILE")
        UPDATED=$(echo "$UPDATED" | jq --arg k "$key" --argjson v "$value" '. + {($k): $v}')
        echo "SET:  '$key'"
        (( set_count++ )) || true
    fi
done < <(jq -r 'keys[]' "$TEMPLATE_FILE" | tr -d '\r')

printf '%s' "$UPDATED" | jq '.' > "$SETTINGS_FILE"
echo ""
echo "Done. Applied $set_count setting(s), skipped $skip_count. Settings file: $SETTINGS_FILE"
