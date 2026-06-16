#!/usr/bin/env bash
# Install bash configuration files (.bashrc, .profile, .bash_profile).
# Each file is symlinked from the repo template. If a real (non-symlink) file
# already exists it is left untouched to avoid overwriting user customisations.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

symlink() {
    local src="$1" dest="$2"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "SKIP: $dest already linked"
    elif [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "SKIP: $dest exists and is not a symlink — skipping to avoid overwrite"
    else
        ln -sf "$src" "$dest"
        echo "SET:  $dest -> $src"
    fi
}

echo "==> Linking bash config files..."
symlink "$SCRIPT_DIR/bashrc"       "$HOME/.bashrc"
symlink "$SCRIPT_DIR/profile"      "$HOME/.profile"
symlink "$SCRIPT_DIR/bash_profile" "$HOME/.bash_profile"

echo ""
echo "Bash settings applied."
