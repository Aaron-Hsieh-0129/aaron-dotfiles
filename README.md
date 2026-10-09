# Aaron's Neovim

My personal Neovim configuration, powered by [LazyVim](https://www.lazyvim.org/).
The personal Lua namespace is `aaron`.

## Features

- LazyVim completion, snippets, diagnostics, code actions, navigation, and shortcut help.
- C/C++ through clangd, CMake tools, Python through Pyright/Ruff, and Git file highlighting.
- clang-format for C/C++/CUDA; StyLua for Lua; isort and Black for Python; Prettier for web files.
- Automatic formatting on save, with a 10-second timeout for slower filesystems.
- nvim-tree with Git status and a 10-second Git timeout, Gitsigns, and Lazygit.
- Snacks project search, Aerial symbols, persistent sessions, tmux navigation, and a Catppuccin Mocha theme.
- Four-space editing indentation and familiar shortcuts alongside LazyVim defaults.

## Install without sudo

Install [Miniforge](https://github.com/conda-forge/miniforge#install) or another Conda distribution in your home directory first. No system package installation or administrator privileges are required by these scripts.

Replace `YOUR_GITHUB_USERNAME` with your GitHub username:

```sh
git clone https://github.com/YOUR_GITHUB_USERNAME/aaron-nvim.git ~/aaron-nvim
cd ~/aaron-nvim
./scripts/setup.sh
./scripts/nvim.sh
```

`setup.sh` runs two independently executable steps:

1. `install.sh` links this checkout to `${XDG_CONFIG_HOME:-~/.config}/nvim` and backs up an existing config, plugin data, and cache. It prints the backup location and is safe to run again on the same checkout. Sessions in the state directory are preserved.
2. `bootstrap.sh` creates a private Conda environment under `${XDG_DATA_HOME:-~/.local/share}/aaron-nvim/runtime`, builds a compatible tree-sitter CLI locally, and waits for language servers, formatters, and parsers to finish installing through Mason/Treesitter. It never invokes sudo or changes your base Conda environment.

The private environment includes Neovim 0.12+, Git, a C compiler, Node.js/npm, Python/pip, Rust/Cargo, curl, tar, unzip, ripgrep, fd, fzf, Lazygit, and CMake. Rust builds tree-sitter CLI from its pinned upstream source because some Linux release binaries require a newer glibc. First installation can take several minutes and needs internet access and disk space for the toolchain.

Keep the checkout in place: Neovim reads your files directly from it. `scripts/nvim.sh` selects the private Neovim and tools while leaving your parent shell unchanged. If your shell's existing `nvim` is already 0.12+, it can also use this configuration. Optionally add an alias pointing to `scripts/nvim.sh`.

If you already have the prerequisites, use:

```sh
./scripts/setup.sh --use-existing
```

This skips creating a Conda environment but still requires Neovim 0.12+ with LuaJIT, Git, curl, tar, unzip, Node.js/npm, Python with pip/venv, Rust/Cargo 1.89+, libclang (set `LIBCLANG_PATH` if needed), and a working C compiler. Install ripgrep, fd, fzf, and Lazygit yourself for search and Git UI functionality. Binaries installed by Mason must support your operating system and CPU architecture; use system/user-installed alternatives if a package is unavailable.

The scripts target Linux/macOS; tested on Linux x86_64 with Neovim 0.12.2 and 0.12.5. On macOS, the compiler toolchain also needs an available platform SDK. On Windows, copy this checkout to `%LOCALAPPDATA%/nvim` and install tools separately.

A Nerd Font is recommended. Configure a clipboard provider if you want clipboard access over SSH. Run `:LazyHealth`, `:Mason`, and `:ConformInfo` to inspect the setup.

Only configuration, scripts, documentation, and plugin version metadata belong in Git. All downloaded plugins, tools, compiled parsers, build caches, and sessions stay in your user directories outside the checkout. Executable paths and credentials are not hardcoded.

## Shortcuts

`<leader>` is Space. LazyVim's default shortcuts remain available; Which-key shows them after pressing Space.

| Shortcut | Action |
| --- | --- |
| `jk` in insert mode | Return to normal mode |
| `Space e` | Toggle file explorer |
| `Space fe` | Reveal current file in explorer |
| `Space ff` / `Space fr` | Find files / recent files |
| `Space fs` / `Space fc` | Search project / word under cursor |
| `Space fk` | Search keybindings |
| `Space mp` / `Space cf` | Format file or selection |
| `Space uf` | Toggle automatic formatting |
| `gd` / `gr` / `K` | Definition / references / hover documentation |
| `Space cr` / `Space ca` | Rename / code actions |
| `Space ch` | Switch C/C++ source and header |
| `Space cs` | Toggle Aerial symbols |
| `Space lg` / `Space gg` | Lazygit |
| `[h` / `]h` | Previous / next Git hunk |
| `Shift h` / `Shift l` | Previous / next buffer |
| `Space bl` / `Space bh` | Move buffer right / left |
| `Space bd` / `Space x` | Close buffer |
| `Space sv` / `Space sh` | Split vertically / horizontally |
| `Space wr` / `Space ws` | Restore / save session |
| `Space cm` | Mason tool manager |

Completion now uses LazyVim's Blink configuration; the previous nvim-cmp-specific insert shortcuts are replaced by LazyVim defaults. Sessions use persistence.nvim. Search uses Snacks. Treesitter uses the current API managed by LazyVim instead of the old `configs` module.

## Personal settings

- `init.lua`: entry point.
- `lua/aaron/lazy.lua`: plugin bootstrap and LazyVim imports.
- `lua/aaron/options.lua`: editor preferences.
- `lua/aaron/keymaps.lua`: personal shortcut aliases.
- `lua/aaron/autocmds.lua`: personal automatic commands.
- `lua/aaron/plugins/`: small overrides for formatting, UI, and navigation.
- `lua/config/`: thin adapters required by LazyVim.
- `lazyvim.json`: enabled language/editor extras.
- `lazy-lock.json`: exact plugin commits, committed for reproducibility.
- `scripts/`: setup, tool installation, launcher, and integration check.

Create `lua/aaron/local.lua` for machine-specific settings; Git ignores it. It loads after plugin setup, so use it for runtime preferences or environment adjustments. Configure plugin specifications in `lua/aaron/plugins/`.

C/C++ completion needs a project compilation database. For a CMake project, configure it with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`; clangd can be pointed to a build directory through the project's `.clangd`. Editing indentation is four spaces; clang-format follows the project's `.clang-format` or its own default style.

## Fix clangd project detection

Clangd needs a compilation database to know a project's include directories, compile definitions, and language settings. Merely attaching the server does not supply those build settings. Run this helper from a configured CMake project:

```sh
python3 ~/aaron-nvim/scripts/prepare-clangd.py build
```

It enables `CMAKE_EXPORT_COMPILE_COMMANDS`, reruns CMake using the build's existing cache, and writes a local `.clangd` pointing to the exported database. For a CPU preset, pass `build_cpu` instead. CMake's existing configure-time checks run again; the helper does not build the application.

For NVHPC builds, it translates compiler-specific flags for clangd and includes the MPI/GCC headers. CUDA builds use host-side CUDA parsing so Kokkos GPU types and annotations are recognized. The helper creates an editor-only database in `build/aaron-clangd/` with explicit commands for headers under `src/` and `include/`. This prevents clangd from losing CUDA mode when you open a header after a source file. Rerun the helper after changing build settings or adding source/header files; the original CMake database stays available to build tools. Prefer the same GCC standard library as the real build:

```sh
python3 ~/aaron-nvim/scripts/prepare-clangd.py build --gcc-toolchain /path/to/gcc11
```

`--cuda-path /path/to/cuda` and `--gpu-arch sm_90` override the toolkit and architecture discovered from CMake/compile commands. `--skip-configure` regenerates editor settings from an already exported database. Existing `.clangd` settings are backed up inside the build directory before replacement; inspect them if you had other custom settings.

Restart Neovim after running the helper. Background indexing may take time on a large project. `.clangd` and `compile_commands.json` contain machine-specific paths and should be ignored by the project repository; neither belongs in this Neovim config repository. On VVMex these files are already ignored. The helper uses the active build's definitions and does not change source code or application compiler flags. Clangd's CUDA analysis is useful for navigation and completion, but the real NVHPC build remains the check for GPU/device compilation.

See [clangd's compilation database documentation](https://clangd.llvm.org/design/compile-commands) and [configuration reference](https://clangd.llvm.org/config).

## Sync and update

On another machine, clone this repository and run `./scripts/setup.sh`. To use the committed plugin versions after pulling changes, run `:Lazy restore`. Run `:Lazy update` only when you intend to update plugins, test the result, then commit the changed lockfile. Tool binaries and compiled parsers are installed locally, so they are not shared through Git. Mason tool versions are not pinned by the plugin lockfile.

Run the integration check after installation:

```sh
./scripts/nvim.sh --headless '+luafile scripts/check.lua'
```

## Restore a backup

`install.sh` prints a backup directory containing `config`, `data`, and `cache`. To restore it, move the current `nvim` config/data/cache aside, then move each backup directory back to the matching XDG location. Keep `${XDG_DATA_HOME:-~/.local/share}/aaron-nvim` if you still want the shared user-installed tools.

On this machine, the complete pre-migration backup is at:

```text
~/.local/state/nvim/config-backups/pre-lazyvim-20261009-151512/
```

Here `nvim-original` is the original config, `nvim-data` the original plugin data, and `nvim-cache` the original cache. These backups stay outside Git.

## Upload to GitHub

Create an empty GitHub repository named `aaron-nvim`, then run these commands in this checkout:

```sh
git add .
git commit -m "Set up Aaron's Neovim configuration"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/aaron-nvim.git
git push -u origin main
```

The original configuration on this machine is backed up separately; backup files, plugin binaries, caches, sessions, and machine-local settings are excluded from this repository.

## Troubleshooting tool installation

If npm reports `ERR_SSL_NO_CIPHER_MATCH` while using Conda/HPC library paths, system Node may be loading incompatible OpenSSL libraries. Launch the tool installer from a clean library environment:

```sh
env -u LD_LIBRARY_PATH nvim
```

The bootstrap script already clears this variable for its own installer process. Use `:Mason` to retry a failed package when installing manually. This command changes the environment for that Neovim process only. Keep project build environments in your usual shell.

## Attribution

The bootstrap is adapted from [LazyVim/starter](https://github.com/LazyVim/starter), with Aaron's namespace and settings. The starter's Apache-2.0 license is included in `LICENSE`; plugins retain their respective licenses.
