# all-settings

Personal settings and install scripts for a new or existing machine.

## Quick start

```bash
git clone --recurse-submodules https://github.com/mankinskin/all-settings.git
cd all-settings
bash install.sh
```

Re-run `install.sh` at any time to apply the latest settings.

On Windows, symlink creation for Vim/Neovim config requires either Developer Mode
or an elevated shell (Administrator).

## What it installs

| Script | What it does |
|---|---|
| `setup.sh` | Initialises git submodules and installs `jq` |
| `bash-settings.sh` | Symlinks `bashrc` → `~/.bashrc`, `profile` → `~/.profile`, `bash_profile` → `~/.bash_profile` |
| `git-settings.sh` | Sets global git config (user, rebase, credential manager, default GitHub account) from `user.env` |
| `vscode-settings.sh` | Merges `vscode-settings.json` into the VSCode user settings file (skips keys that are already set) |
| `vscode-settings-sync.sh` | Reverse of `vscode-settings.sh`: pulls changes from the live VSCode `settings.json` back into the `vscode-settings.json` template, prompting for each diff |
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

Edit `user.env` before running the installer to set your name, e-mail, and GitHub username for git:

```bash
export USER_EMAIL="you@example.com"
export USER_FULL_NAME="Your Name"
export GITHUB_USERNAME="your-github-username"
```

Git identity fields are only written when they are not already set — existing values are preserved.
The GitHub default account is written to `credential.https://github.com.username`.

## Syncing VSCode settings back to the repo

After tweaking settings live in VSCode, pull those changes back into the
tracked template so they can be committed:

```bash
bash vscode-settings-sync.sh        # walks each diff and asks for confirmation
bash vscode-settings-sync.sh --yes  # apply every change without prompting
```

It reports added, modified, and removed keys compared with the active
`settings.json`. Review and commit `vscode-settings.json` afterwards.
