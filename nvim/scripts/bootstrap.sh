#!/bin/sh
# Install runtime dependencies in user-owned directories. Never invokes sudo.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
tools_root="${XDG_DATA_HOME:-$HOME/.local/share}/aaron-nvim"
use_existing=false
case "${1:-}" in
    --use-existing) use_existing=true ;;
    --help) printf '%s\n' 'Usage: ./scripts/bootstrap.sh [--use-existing]' 'Default: create a private Conda environment for all prerequisites.' '--use-existing: use installed prerequisites and Cargo; still install Neovim tools.'; exit 0 ;;
    "") ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
esac
# Avoid a system Node/Conda OpenSSL conflict during installation only.
unset LD_LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
mkdir -p "$tools_root"
if [ "$use_existing" = false ]; then
    if ! command -v conda >/dev/null 2>&1; then
        printf '%s\n' 'Install Miniforge in your home directory first:' 'https://github.com/conda-forge/miniforge#install' 'Then run this script again. No sudo is needed.' >&2
        exit 1
    fi
    if [ -f "$tools_root/runtime/conda-meta/history" ]; then
        conda_action=install
    else
        conda_action=create
    fi
    conda "$conda_action" --prefix "$tools_root/runtime" --channel conda-forge --override-channels --yes \
        'nvim>=0.12' git curl tar unzip nodejs python pip ripgrep fd-find lazygit fzf cmake make \
        'rust>=1.89' c-compiler libclang clang clang-tools pkg-config openssl
    # Activate compiler variables as well as executable search paths.
    eval "$(conda shell.posix hook)"
    conda activate "$tools_root/runtime"
    LIBCLANG_PATH="$tools_root/runtime/lib"
    export LIBCLANG_PATH
fi
for cmd in nvim git curl tar unzip node npm python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'Missing %s. Run without --use-existing to install prerequisites through Conda.\n' "$cmd" >&2
        exit 1
    fi
done
nvim --headless -u NONE '+lua if vim.fn.has("nvim-0.12") == 0 then vim.cmd("cquit 1") end' '+qa!' || {
    printf '%s\n' 'Neovim 0.12+ is required. Run without --use-existing to install it through Conda.' >&2
    exit 1
}
# libclang packages may omit builtin headers; GCC supplies the C headers needed by bindgen.
if [ -z "${BINDGEN_EXTRA_CLANG_ARGS:-}" ]; then
    build_compiler=${CC:-cc}
    compiler_include=$("$build_compiler" -print-file-name=include 2>/dev/null || true)
    if [ -d "$compiler_include" ]; then
        BINDGEN_EXTRA_CLANG_ARGS="-isystem $compiler_include"
        export BINDGEN_EXTRA_CLANG_ARGS
    fi
fi
# Build locally: upstream Linux CLI binaries may require a newer glibc.
# --use-existing also needs libclang; set LIBCLANG_PATH if it is not discoverable.
# This version meets the requirement of the committed Treesitter plugin.
if ! "$tools_root/bin/tree-sitter" --version >/dev/null 2>&1; then
    if ! command -v cargo >/dev/null 2>&1; then
        printf '%s\n' 'Cargo/Rust is needed to build tree-sitter. Run without --use-existing to install it with Conda.' >&2
        exit 1
    fi
    cargo install --git https://github.com/tree-sitter/tree-sitter --tag v0.26.1 --locked tree-sitter-cli --root "$tools_root" --jobs 4
fi
PATH="$tools_root/bin:$PATH"
export PATH
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
if [ ! -f "$config_dir/init.lua" ]; then
    printf '%s\n' 'Run ./scripts/install.sh before bootstrap.sh.' >&2
    exit 1
fi
# Keep Neovim open until asynchronous Mason and parser installations complete.
AARON_NVIM_REPO="$repo_dir"
export AARON_NVIM_REPO
nvim --headless '+lua dofile(vim.env.AARON_NVIM_REPO .. "/scripts/install-tools.lua")'
printf '%s\n' 'Tools installed locally; nothing downloaded is placed in the Git checkout.'
if [ "$use_existing" = false ]; then
    printf 'Launch with: %s/runtime/bin/nvim\n' "$tools_root"
fi
