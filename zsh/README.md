# Aaron's zsh

The shell component of [Aaron's dotfiles](../README.md). Run component-specific commands from `~/aaron-dotfiles/zsh`, or use shared setup from the repository root.

Portable version of Aaron's current zsh setup: Powerlevel10k, Oh My Zsh Git aliases, completions, history substring search, autosuggestions, syntax highlighting, and automatic bracket pairing. Plugin commits are pinned in `plugins.lock.tsv`; plugin source and binaries install outside this repository.

## Install without sudo

Keep this checkout at a permanent location, such as `~/aaron-dotfiles`, then run:

```sh
cd ~/aaron-dotfiles/zsh
./scripts/setup.sh
./scripts/zsh.sh
```

If zsh 5.8+ and Git are already available, setup uses them. Otherwise install [Miniforge](https://github.com/conda-forge/miniforge#install) in your home directory, then rerun setup. It creates a private Conda environment under `${XDG_DATA_HOME:-~/.local/share}/aaron-zsh/runtime` only when zsh/Git are missing. For an existing environment, `./scripts/setup.sh --use-existing` requires both tools and skips Conda installation.

Setup downloads the exact plugin commits, then links `~/.zshrc` to this checkout (or `$ZDOTDIR/.zshrc` if set). Existing configuration is backed up under `${XDG_STATE_HOME:-~/.local/state}/aaron-zsh/backups/`. Running setup again restores the pinned plugin versions and keeps the existing link. It stops if a downloaded plugin has local edits. No sudo, system packages, or login-shell changes are required.

Try the template before replacing `.zshrc`:

```sh
./scripts/bootstrap.sh --use-existing
./scripts/zsh.sh
```

The launcher opens a shell using this checkout through `ZDOTDIR`; your existing startup file stays available. Type `exit` to return. If your system zsh is already suitable, normal new zsh sessions use the installed `.zshrc`. If zsh was installed privately, launch it with `scripts/zsh.sh`; changing your account's login shell is optional and may require your administrator on managed machines. `ZDOTDIR` is inherited by nested zsh sessions launched from the wrapper.

## Machine-specific settings

```sh
mkdir -p ~/.config/aaron-zsh
cp local.example.zsh ~/.config/aaron-zsh/local.zsh
```

The initial checkout includes an ignored `local.zsh` with this machine's existing HPC paths and automatic profile activation. It will not be uploaded; on a new machine use the example. Adjust the local file for that machine. It loads before plugins and is outside Git. `local.zsh` in the checkout is also supported and ignored by Git; it loads after the external local file. `AARON_ZSH_LOCAL_FILE` can select another external file. `AARON_ZSH_LOAD_LOCAL=0` skips both local files for an isolated portable session. `AARON_ZSH_DATA` can select the user plugin/runtime directory.

Conda initialization uses `shell.zsh hook`, detects common home-directory installs, and leaves base activation off. Set `AARON_CONDA_EXE` for a custom install or `AARON_ZSH_CONDA=0` to disable it. Use `conda activate` to select an environment. Library/include paths are only set by optional project profiles; the portable shell does not inject the base Conda libraries into every program.

For the existing NVHPC/MPI/VVM workflow, fill in `NVHPC_ROOT`, `INSTALL_DIR`, `INSTALL_DIR2`, `VVM_ROOT`, and optionally `HPCX_HOME` in the example local file. Run `vvm-env` to activate `profiles/nvhpc.zsh` in that shell. Use a separate shell for a different toolchain. This profile uses existing installations; it does not download NVHPC, MPI, CUDA, VVM libraries, or OpenGrADS. Set `AARON_MPI_TMP_ROOT` if your cluster needs MPI temporary files outside `/tmp`. Set the optional OpenGrADS path yourself. You can source the profile from the local file to activate it automatically.

Slurm aliases are defined when their commands exist: `q` (current user's jobs), `sqp`, `si`, `sb`, `sj`, `sp`, and `no`. The GPFS quota command `qu` is available on machines with `mmlsquota`. `vvmex` and `vvm` use `VVM_ROOT` and `VVM_GPU_ROOT`.

The `nvim` function uses the installed [Aaron's Neovim](https://github.com/Aaron-Hsieh-0129/aaron-dotfiles) launcher in the sibling `nvim/` directory when present, with the installed config path as a fallback. `EDITOR` and `VISUAL` use the combined repository's `bin/nvim`. Set `AARON_NVIM_LAUNCHER` for a custom location. Otherwise it runs Neovim from PATH. This keeps the editor's private compiler tools out of the shell's build environment.

## Prompt and editing

`config/p10k.zsh` preserves the active settings from Aaron's existing generated Powerlevel10k configuration with comments condensed. Configure a Nerd Font in your terminal for its icons. Powerlevel10k may install its platform-specific Git helper into the user's cache; compiled dependencies stay outside Git. Its upstream [installation guide](https://github.com/romkatv/powerlevel10k#installation) describes supported terminals and fonts.

For a different prompt, run `p10k configure`, then copy the generated `~/.p10k.zsh` to `config/p10k.zsh` if you want to share it. No wizard runs automatically on startup. Instant prompt stays disabled, matching Aaron's existing configuration. Syntax highlighting loads after other ZLE widgets as required by its [upstream instructions](https://github.com/zsh-users/zsh-syntax-highlighting#faq).

Arrow keys search history for the substring already typed. Autosuggestions and bracket pairing work alongside completions. Oh My Zsh provides Git shortcuts. History is stored locally under `${XDG_STATE_HOME:-~/.local/state}/aaron-zsh/history`.

## Update, verify, and publish

```sh
./scripts/check.sh
```

This checks syntax, startup with the installed plugins, path deduplication, and the installer's backup/idempotence using temporary config/state directories. It does not replace your real `.zshrc`.

To update plugins, change the relevant full Git commit in `plugins.lock.tsv`, run bootstrap, and rerun the check. Startup never performs network downloads or update prompts, apart from Powerlevel10k's optional platform Git helper setup.

Zsh and Neovim share one Git repository. Use the [root publishing instructions](../README.md#update-and-publish), and commit changes under `zsh/` together with any editor updates. On another machine, clone the combined repository and run its shared `./scripts/setup.sh`, or `./scripts/setup.sh --only zsh` for the shell alone.

To restore the previous shell configuration, remove the installed `.zshrc` symlink and move the `.zshrc` from the backup directory printed by the installer to its original location.

Tested on Linux x86_64. The scripts use Bash, Git, and zsh and target Linux/macOS. Plugins retain their own upstream licenses; this repository contains configuration and install scripts rather than vendored plugin code.
