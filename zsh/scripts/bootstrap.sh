#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
data="${AARON_ZSH_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/aaron-zsh}"
use_existing=0
case "${1:-}" in
    --use-existing) use_existing=1; shift ;;
    '') ;;
    *) printf 'Usage: %s [--use-existing]\n' "$0" >&2; exit 2 ;;
esac
[[ $# == 0 ]] || { printf 'Unexpected arguments\n' >&2; exit 2; }
# Avoid mixed Conda/HPC libraries during downloads and package installation.
unset LD_LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
if [[ -x "$data/runtime/bin/zsh" && -x "$data/runtime/bin/git" ]]; then
    export PATH="$data/runtime/bin:$PATH"
fi
zsh_ready=0
if command -v zsh >/dev/null && zsh -fc 'autoload -Uz is-at-least; is-at-least 5.8'; then
    zsh_ready=1
fi
if (( ! zsh_ready )) || ! command -v git >/dev/null; then
    if (( use_existing )); then
        printf 'Install zsh 5.8+ and Git in your user environment first.\n' >&2
        exit 1
    fi
    conda_exe="${AARON_CONDA_EXE:-${CONDA_EXE:-}}"
    if [[ ! -x "$conda_exe" ]]; then conda_exe=$(command -v conda || true); fi
    [[ -x "$conda_exe" ]] || { printf 'Install Miniforge in your home directory, then rerun setup (no sudo needed).\n' >&2; exit 1; }
    mkdir -p "$data"
    if [[ -f "$data/runtime/conda-meta/history" ]]; then
        "$conda_exe" install -y -p "$data/runtime" -c conda-forge zsh git
    else
        "$conda_exe" create -y -p "$data/runtime" -c conda-forge zsh git
    fi
    export PATH="$data/runtime/bin:$PATH"
fi
zsh -fc 'autoload -Uz is-at-least; is-at-least 5.8' || { printf 'zsh 5.8+ is required.\n' >&2; exit 1; }
mkdir -p "$data/plugins"
while IFS=$'\t' read -r name url commit; do
    [[ -n "$name" && "$name" != \#* ]] || continue
    destination="$data/plugins/$name"
    printf 'Installing %s at %s\n' "$name" "${commit:0:12}"
    if [[ ! -e "$destination" ]]; then
        git init -q "$destination"
        git -C "$destination" remote add origin "$url"
    fi
    [[ -d "$destination/.git" ]] || { printf 'Not a plugin Git checkout: %s\n' "$destination" >&2; exit 1; }
    [[ -z $(git -C "$destination" status --porcelain) ]] || { printf 'Plugin has local edits: %s\n' "$destination" >&2; exit 1; }
    if ! git -C "$destination" cat-file -e "$commit^{commit}" 2>/dev/null; then
        git -C "$destination" fetch --depth 1 origin "$commit"
    fi
    git -C "$destination" -c advice.detachedHead=false checkout -q --detach "$commit"
done < "$repo/plugins.lock.tsv"
printf 'Installed zsh plugins in %s/plugins\n' "$data"
