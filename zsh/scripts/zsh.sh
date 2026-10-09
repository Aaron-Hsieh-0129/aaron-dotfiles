#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
data="${AARON_ZSH_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/aaron-zsh}"
source "$repo/scripts/runtime.sh"
shell=$(aaron_zsh_select "$data") || {
    printf 'No working zsh 5.8+ found (startup must be free of library warnings).\nRun %s/scripts/bootstrap.sh to install or repair the private runtime.\n' "$repo" >&2
    exit 1
}
if [[ "$shell" == "$data/"* ]]; then
    export PATH="$(dirname -- "$shell"):$data/runtime/bin:$PATH"
fi
export AARON_ZSH_ROOT="$repo"
export ZDOTDIR="$repo"
exec "$shell" "$@"
