#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
target="$HOME/.tmux.conf"
[[ -f "$repo/.tmux.conf" && ! -L "$repo/.tmux.conf" ]] || { printf 'Checkout .tmux.conf must be a regular file.\n' >&2; exit 1; }
if [[ "$target" -ef "$repo/.tmux.conf" ]]; then
    printf 'Already using %s\n' "$target"
    exit 0
fi
mkdir -p "$HOME"
if [[ -e "$target" || -L "$target" ]]; then
    state="${XDG_STATE_HOME:-$HOME/.local/state}/aaron-tmux/backups"
    mkdir -p "$state"
    backup=$(mktemp -d "$state/$(date +%Y%m%d-%H%M%S).XXXXXXXX")
    mv "$target" "$backup/.tmux.conf"
    printf 'Previous config backed up to %s\n' "$backup"
fi
ln -s "$repo/.tmux.conf" "$target"
printf 'Linked %s → %s/.tmux.conf\n' "$target" "$repo"
