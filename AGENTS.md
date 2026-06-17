# AGENTS.md

Coding agent rules for the `all-settings` repository.

## Purpose
This repo manages personal dotfiles and editor settings. Every script is a
thin installer — keep scripts simple, idempotent, and safe to re-run.

## Rules

- **All scripts must be idempotent.** Re-running `install.sh` must never
  destructively overwrite an existing non-symlink file.
- **Never clobber real files.** Use the `symlink()` pattern: skip if the
  destination exists and is not a symlink.
- **`install.sh` is the single entry point.** Every new settings script must
  be called from `install.sh`. Do not require users to run individual scripts.
- **`setup.sh` installs dependencies.** Add new system-level dependencies
  there, not inline in other scripts.
- **Guard on availability.** Before installing editor config, check that the
  editor is installed (e.g. `command -v nvim`). Skip gracefully if not found.
- **Template files have no extension.** Dotfile templates live at the repo
  root without a leading dot (e.g. `bashrc`, `profile`, `bash_profile`).
- **Settings scripts are named `<tool>-settings.sh`** or `install.sh` inside
  a submodule folder.
- **Update the README table** when adding a new script or template.
- **No secrets in tracked files.** Keep personal data (email, name) in
  `user.env` only; never hard-code it elsewhere.
