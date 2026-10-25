#!/usr/bin/env bash
set -euo pipefail
umask 077
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
target="${ZDOTDIR:-$HOME}/.zshrc"
if [[ ! -f "$repo/.zshrc" || -L "$repo/.zshrc" ]]; then
    printf 'Checkout startup file must be a regular file: %s/.zshrc\nRestore it from Git before running the installer.\n' "$repo" >&2
    exit 1
fi
mkdir -p "$(dirname -- "$target")"
# The launcher exports ZDOTDIR to this checkout. Installing from that shell
# must not move the source away and replace it with a link to itself.
target_dir=$(cd -- "$(dirname -- "$target")" && pwd -P)
if [[ "$target_dir" == "$repo" ]]; then
    printf 'Already using checkout startup file: %s/.zshrc\n' "$repo"
    printf 'To link your home startup file, run: env -u ZDOTDIR %s/scripts/install.sh\n' "$repo"
    exit 0
fi
if [[ -L "$target" && "$target" -ef "$repo/.zshrc" ]]; then
    printf 'Already linked: %s\n' "$target"
    exit 0
fi
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
