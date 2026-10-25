#!/usr/bin/env bash
set -euo pipefail
scripts=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$scripts/runtime.sh"
for script in "$scripts"/*.sh "$scripts/../../bin/tmux"; do bash -n "$script"; done
data="${AARON_TMUX_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/aaron-tmux}"
tmux_exe=$(aaron_tmux_select "$data") || { printf 'Run setup to install tmux first.\n' >&2; exit 1; }
"$tmux_exe" -V
printf 'PASS: shell syntax and tmux version check\n'
