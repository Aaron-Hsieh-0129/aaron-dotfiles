#!/usr/bin/env bash
set -euo pipefail
scripts=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
data="${AARON_TMUX_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/aaron-tmux}"
use_existing=0
case "${1:-}" in
    --use-existing) use_existing=1; shift ;;
    '') ;;
    *) printf 'Usage: %s [--use-existing]\n' "$0" >&2; exit 2 ;;
esac
[[ $# == 0 ]] || { printf 'Unexpected arguments\n' >&2; exit 2; }
unset LD_LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH
source "$scripts/runtime.sh"
if ! tmux_exe=$(aaron_tmux_select "$data"); then
    if (( use_existing )); then
        printf 'Install a working tmux first, or rerun without --use-existing.\n' >&2
        exit 1
    fi
    conda_exe="${AARON_CONDA_EXE:-${CONDA_EXE:-}}"
    if [[ ! -x "$conda_exe" ]]; then conda_exe=$(command -v conda || true); fi
    if [[ ! -x "$conda_exe" ]]; then
        for candidate in "$HOME/miniforge3/bin/conda" "$HOME/miniconda3/bin/conda" "$HOME/mambaforge/bin/conda"; do
            if [[ -x "$candidate" ]]; then conda_exe=$candidate; break; fi
        done
    fi
    [[ -x "$conda_exe" ]] || { printf 'Install Miniforge in your home directory, then rerun setup (no sudo needed).\n' >&2; exit 1; }
    mkdir -p "$data"
    if [[ -f "$data/runtime/conda-meta/history" ]]; then
        "$conda_exe" install -y -p "$data/runtime" --override-channels -c conda-forge --strict-channel-priority tmux
    else
        "$conda_exe" create -y -p "$data/runtime" --override-channels -c conda-forge --strict-channel-priority tmux
    fi
    tmux_exe=$(aaron_tmux_select "$data") || { printf 'tmux installation failed its version check.\n' >&2; exit 1; }
fi
"$tmux_exe" -V
"$scripts/install.sh"
printf 'Launch with %s/../../bin/tmux\n' "$scripts"
