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
echo "==> Applying git settings..."
( cd "$SCRIPT_DIR" && bash git-settings.sh )

echo ""
echo "==> Applying VSCode settings..."
bash "$SCRIPT_DIR/vscode-settings.sh"

echo ""
echo "==> Applying vim settings..."
VIMRC_SRC="$SCRIPT_DIR/vimrc/vimrc"
VIMRC_DEST="$HOME/.vimrc"
if [ -f "$VIMRC_SRC" ]; then
    if [ -e "$VIMRC_DEST" ] && [ ! -L "$VIMRC_DEST" ]; then
        echo "SKIP: ~/.vimrc already exists and is not a symlink — skipping to avoid overwrite."
    elif [ -L "$VIMRC_DEST" ] && [ "$(readlink "$VIMRC_DEST")" = "$VIMRC_SRC" ]; then
        echo "SKIP: ~/.vimrc symlink already up to date."
    else
        ln -sf "$VIMRC_SRC" "$VIMRC_DEST"
        echo "SET:  ~/.vimrc -> $VIMRC_SRC"
    fi
else
    echo "SKIP: vimrc submodule not found at $VIMRC_SRC"
fi

echo ""
echo "========================================"
echo " All settings applied successfully."
echo "========================================"
