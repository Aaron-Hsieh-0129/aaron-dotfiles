#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
target="${ZDOTDIR:-$HOME}/.zshrc"
if [[ -L "$target" && "$target" -ef "$repo/.zshrc" ]]; then
    printf 'Already linked: %s\n' "$target"
    exit 0
fi
mkdir -p "$(dirname -- "$target")"
if [[ -e "$target" || -L "$target" ]]; then
    backup=$(mktemp -d "${TMPDIR:-/tmp}/aaron-zsh-backup.XXXXXXXX")
    state="${XDG_STATE_HOME:-$HOME/.local/state}/aaron-zsh/backups"
    mkdir -p "$state"
    backup_name="$(date +%Y%m%d-%H%M%S)-${backup##*.}"
    mv "$backup" "$state/$backup_name"
    backup="$state/$backup_name"
    mv "$target" "$backup/.zshrc"
    printf 'Previous config backed up to %s\n' "$backup"
fi
ln -s "$repo/.zshrc" "$target"
printf 'Linked %s → %s/.zshrc\n' "$target" "$repo"
printf 'Start a new shell with %s/scripts/zsh.sh\n' "$repo"
