#!/usr/bin/env bash
# Export the currently installed VS Code extensions into the tracked list.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/vscode-extensions.txt"

if ! command -v code &>/dev/null; then
    echo "SKIP: VS Code CLI not found — skipping extension export."
    exit 0
fi

mkdir -p "$(dirname "$EXTENSIONS_FILE")"

code --list-extensions | tr -d '\r' | sed '/^[[:space:]]*$/d' | sort -u > "$EXTENSIONS_FILE"

count=$(wc -l < "$EXTENSIONS_FILE" | tr -d ' ')
echo "Wrote $count extension(s) to $EXTENSIONS_FILE"
