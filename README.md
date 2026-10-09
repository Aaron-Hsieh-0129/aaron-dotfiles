# Aaron's dotfiles

One portable repository for Aaron's Neovim and zsh configuration. Neovim uses LazyVim, Catppuccin Mocha, clangd, formatters, and Git tools. Zsh uses Powerlevel10k, Oh My Zsh Git aliases, completions, history search, autosuggestions, syntax highlighting, and bracket pairing.

The combined repository name is **aaron-dotfiles**. The existing GitHub repository is currently `Aaron-Hsieh-0129/neovim-setup`; rename that same repository to `aaron-dotfiles` in **Settings → General → Repository name** before using the new clone URL below. The recommended description is “Aaron's portable Neovim and zsh configuration with no-sudo setup.” Renaming the existing repository keeps its Git history. There is no need to create another repository.

## Install without sudo

Install [Miniforge](https://github.com/conda-forge/miniforge#install) in your home directory first for the default Neovim tool installation. Then:

```sh
git clone https://github.com/Aaron-Hsieh-0129/aaron-dotfiles.git ~/aaron-dotfiles
cd ~/aaron-dotfiles
./scripts/setup.sh
./bin/zsh
```

`setup.sh` installs dependencies in your user directories, links `nvim/` to `${XDG_CONFIG_HOME:-~/.config}/nvim`, and links `zsh/.zshrc` to `~/.zshrc` (or `$ZDOTDIR/.zshrc` when set). Existing files and Neovim runtime directories are backed up. The checkout must remain in place because the installed configs use it directly.

Neovim's private toolchain remains under `${XDG_DATA_HOME:-~/.local/share}/aaron-nvim`; zsh plugins and its optional private runtime remain under `${XDG_DATA_HOME:-~/.local/share}/aaron-zsh`. These component directories are local runtime storage, independent of the repository's name. Binaries, downloaded plugins, caches, history, sessions, secrets, and machine-specific overrides stay out of Git.

Use existing prerequisites, or choose a single component:

```sh
./scripts/setup.sh --use-existing
./scripts/setup.sh --only nvim
./scripts/setup.sh --only zsh --use-existing
```

`--use-existing` requires the tools listed in the component guides. `./scripts/install.sh` links configurations without installing dependencies; it also accepts `--only nvim` or `--only zsh`. You can inspect available options with `--help`. Setup never changes your account's login shell.

## Use and customize

| Path | Purpose |
| --- | --- |
| `bin/nvim` | Launch Neovim with its private tools |
| `bin/zsh` | Launch zsh using this checkout |
| `scripts/setup.sh` | Install and link both components |
| `scripts/install.sh` | Link both components with backups |
| `scripts/check.sh` | Run both integration checks |
| `nvim/` | LazyVim configuration, locks, language tools, and clangd helper |
| `zsh/` | Shell configuration, plugin lock, and optional HPC profile |

See the [Neovim guide](nvim/README.md) for keybindings, language tools, and [clangd/CUDA project setup](nvim/README.md#fix-clangd-project-detection). See the [zsh guide](zsh/README.md) for shell settings and the NVHPC/MPI profile.

Machine-specific files:

- Neovim: `nvim/lua/aaron/local.lua`, ignored by Git.
- Zsh: `${XDG_CONFIG_HOME:-~/.config}/aaron-zsh/local.zsh`, or ignored `zsh/local.zsh`. Copy `zsh/local.example.zsh` as a starting point.

Zsh's `nvim` function and editor settings use the Neovim component in the same checkout. `AARON_NVIM_LAUNCHER` can override that integration. Activate the optional compiler environment with `vvm-env` after filling in your machine's paths. The initial local migration preserves this machine's HPC settings in an ignored file.

## Update and publish

After renaming the existing GitHub repository:

```sh
cd ~/aaron-dotfiles
git remote set-url origin https://github.com/Aaron-Hsieh-0129/aaron-dotfiles.git
git add .
git diff --cached --check
git commit -m "Combine Neovim and zsh in Aaron's dotfiles"
git push origin main
```

The local migration preserves the original Neovim repository's history. The existing remote URL remains usable until the GitHub rename is done. GitHub naming and remote changes do not require reinstalling runtime tools.

On another machine, pull changes with `git pull --ff-only`, use `:Lazy restore` in Neovim, and rerun setup when dependency requirements or zsh plugin pins change. To update plugins intentionally, edit/test the relevant component lockfile and commit it.

```sh
./scripts/check.sh
# Or check only one component:
./scripts/check.sh --only nvim
./scripts/check.sh --only zsh
```

The checks validate editor formatting/LSP/Treesitter/Git integration and shell startup/plugins/path handling/installer backups. Zsh checks use temporary config directories. The Neovim check creates and removes a temporary Git fixture.

## Migration and backups

This machine's combined checkout is `/work/aaron900129/aaron-dotfiles`. The previous `aaron-nvim` and `aaron-zsh` checkout paths are compatibility symlinks to the respective component directories. The installed Neovim config points directly to `nvim/` in the combined checkout. These compatibility links are local and are not part of the repository.

The original zsh template repository and migration metadata are backed up under `~/.local/state/aaron-dotfiles/migration/`. Installers print their own backup paths under the component's state directory. Your previous shell startup file remains in use until you run the zsh installer or combined setup.

The installation scripts target Linux/macOS; Linux x86_64 is tested. Read each component guide for platform dependencies, restoration instructions, and upstream attribution. The Neovim starter license is retained in `nvim/LICENSE`; plugins retain their own licenses.
