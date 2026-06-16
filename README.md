# all-settings

Personal settings and install scripts for a new or existing machine.

## Quick start

```bash
git clone --recurse-submodules https://github.com/mankinskin/all-settings.git
cd all-settings
bash install.sh
```

Re-run `install.sh` at any time to apply the latest settings.

## What it installs

| Script | What it does |
|---|---|
| `setup.sh` | Initialises git submodules and installs `jq` |
| `git-settings.sh` | Sets global git config (user, rebase, credential helper) from `user.env` |
| `vscode-settings.sh` | Merges `vscode-settings.json` into the VSCode user settings file (skips keys that are already set) |
| `vimrc/install.sh` | Symlinks `vimrc` → `~/.config/nvim/init.vim`, installs vim-plug, installs all plugins via `:PlugInstall` |

## Submodules

- **vimrc** — `~/.vimrc` config with vim-plug plugin management

## Updating

Pull the latest changes and re-run the installer:

```bash
git pull --recurse-submodules
bash install.sh
```

## Customising user identity

Edit `user.env` before running the installer to set your name and e-mail for git:

```bash
export USER_EMAIL="you@example.com"
export USER_FULL_NAME="Your Name"
```

Git identity fields are only written when they are not already set — existing values are preserved.
