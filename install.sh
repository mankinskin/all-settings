#!/usr/bin/env bash
# Single entry point to apply all settings from this repository.
# Run this script after cloning to set up a new machine, or re-run at any
# time to update settings.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo " all-settings installer"
echo "========================================"
echo ""

echo "==> Running setup (dependencies + submodules)..."
bash "$SCRIPT_DIR/setup.sh"

echo ""
echo "==> Applying bash settings..."
bash "$SCRIPT_DIR/bash-settings.sh"

echo ""
echo "==> Applying git settings..."
( cd "$SCRIPT_DIR" && bash git-settings.sh )

echo ""
echo "==> Applying VSCode settings..."
bash "$SCRIPT_DIR/vscode-settings.sh"

echo ""
echo "==> Applying vim/neovim settings..."
if [ -f "$SCRIPT_DIR/vimrc/install.sh" ]; then
    bash "$SCRIPT_DIR/vimrc/install.sh"
else
    echo "SKIP: vimrc/install.sh not found — submodule may not be initialised."
fi

echo ""
echo "========================================"
echo " All settings applied successfully."
echo "========================================"
