# AGENTS.md

A description of the `all-settings` repository. Read top to bottom: earlier
sections frame the sections that follow. Preserve this structure: every change
keeps the patterns below intact, and validates the scripts still run cleanly.

## Purpose
This repo manages personal dotfiles and editor settings. Each script applies
one tool's configuration and leaves existing user state in place.

## Core Behavior
- A non-symlink file at a destination stays untouched; the script skips it and
  reports the skip.
- `install.sh` is the single entry point. It runs `setup.sh` first, then each
  settings script in sequence.
- Scripts are idempotent. Re-running changes state only when something is
  missing or new, and reports what it skips.

## Environment And Dependencies
- `setup.sh` initializes submodules and installs dependencies such as `jq`.
  All system packages and setup steps live here.
- Each script checks that its editor or CLI (`nvim`, `vim`, `code`, `jq`)
  exists before acting, and exits `0` with a `SKIP` message when it is absent.
- Scripts run under Git Bash on Windows: they use the AppData paths, the
  PowerShell symlink-to-hardlink fallback, and `cygpath` path translation.

## Script Patterns
- Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` resolves the
  script directory, and repo files are referenced through it.
- Every action prints a `SET:`, `SKIP:`, `MIGRATE:`, `INSTALL:`, or `ERROR:`
  line, and the script ends with a summary count.
- Scripts are thin shims over shared state and carry no logic beyond applying
  their configuration.
- A script that writes to a live target has a matching `*-sync.sh` counterpart
  that exports live state back into the tracked file.
- Interactive scripts accept a `-y`/`--yes` flag that applies every change
  without prompting.
- Tracked exports such as `vscode-extensions.txt` stay sorted and deduplicated.

## Repository Structure And Naming
- Dotfile templates sit at the repo root with no leading dot and no extension
  (`bashrc`, `profile`, `bash_profile`).
- Settings scripts are named `<tool>-settings.sh`; submodules carry their own
  `install.sh`.
- The README table lists every script and tracked export, and grows in the same
  change that adds one.
- Personal data—name, e-mail, GitHub identity—lives only in `user.env`.
