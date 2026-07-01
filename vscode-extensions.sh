#!/usr/bin/env bash
# Install the tracked VS Code extensions list into the current VS Code profile.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/vscode-extensions.txt"

if ! command -v code &>/dev/null; then
    echo "SKIP: VS Code CLI not found — skipping extension install."
    exit 0
fi

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "ERROR: extension list not found: $EXTENSIONS_FILE" >&2
    exit 1
fi

INSTALLED_EXTENSIONS="$(code --list-extensions | tr -d '\r')"
installed_count=0
skipped_count=0

while IFS= read -r extension; do
    extension="${extension//$'\r'/}"
    [ -z "$extension" ] && continue

    if echo "$INSTALLED_EXTENSIONS" | grep -Fxq "$extension"; then
        echo "SKIP: $extension is already installed"
        (( skipped_count++ )) || true
    else
        echo "INSTALL: $extension"
        code --install-extension "$extension"
        (( installed_count++ )) || true
    fi
done < "$EXTENSIONS_FILE"

echo ""
echo "Done. Installed $installed_count extension(s), skipped $skipped_count."
