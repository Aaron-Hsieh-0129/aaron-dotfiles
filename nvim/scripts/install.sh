#!/bin/sh
# Install this checkout; preserve an existing config and its runtime directories.
set -eu
umask 077
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
config_root=${XDG_CONFIG_HOME:-"$HOME/.config"}
data_root=${XDG_DATA_HOME:-"$HOME/.local/share"}
cache_root=${XDG_CACHE_HOME:-"$HOME/.cache"}
state_root=${XDG_STATE_HOME:-"$HOME/.local/state"}
target="$config_root/nvim"
mkdir -p "$config_root"
if [ -L "$target" ] && [ "$(CDPATH= cd -- "$target" && pwd -P)" = "$repo_dir" ]; then
    printf 'Already installed: %s\n' "$target"
    exit 0
fi
mkdir -p "$state_root/aaron-nvim/backups"
backup=$(mktemp -d "$state_root/aaron-nvim/backups/$(date +%Y%m%d-%H%M%S).XXXXXXXX")
if [ -e "$target" ] || [ -L "$target" ]; then
    mv "$target" "$backup/config"
fi
if [ -d "$data_root/nvim" ]; then
    mv "$data_root/nvim" "$backup/data"
fi
if [ -d "$cache_root/nvim" ]; then
    mv "$cache_root/nvim" "$backup/cache"
fi
ln -s "$repo_dir" "$target"
printf 'Installed: %s -> %s\nBackup: %s\nOpen nvim and allow plugins and tools to finish installing.\n' "$target" "$repo_dir" "$backup"
