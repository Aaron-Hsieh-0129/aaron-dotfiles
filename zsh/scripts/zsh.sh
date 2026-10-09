#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
data="${AARON_ZSH_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/aaron-zsh}"
if [[ -x "$data/runtime/bin/zsh" ]]; then
    shell="$data/runtime/bin/zsh"
    export PATH="$data/runtime/bin:$PATH"
else
    shell=$(command -v zsh || true)
fi
[[ -n "$shell" ]] || { printf 'Run scripts/bootstrap.sh first to install zsh.\n' >&2; exit 1; }
export AARON_ZSH_ROOT="$repo"
export ZDOTDIR="$repo"
exec "$shell" "$@"
