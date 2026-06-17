#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Initializing submodules..."
git -C "$SCRIPT_DIR" submodule update --init --recursive

echo ""
echo "==> Checking dependencies..."

if command -v jq &>/dev/null; then
    echo "jq already installed ($(jq --version))"
else
    echo "Installing jq..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y jq
    elif command -v brew &>/dev/null; then
        brew install jq
    elif command -v winget &>/dev/null; then
        winget install jqlang.jq
    elif command -v choco &>/dev/null; then
        choco install jq -y
    elif command -v scoop &>/dev/null; then
        scoop install jq
    else
        echo "ERROR: Cannot install jq automatically. Please install it from https://jqlang.org/" >&2
        exit 1
    fi
    echo "jq installed."
fi

echo ""
echo "Setup complete."
