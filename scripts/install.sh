#!/usr/bin/env bash
# Link both components, preserving existing startup files and Neovim data.
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
parse_options "$@"
for component in "${components[@]}"; do
    "$DOTFILES_ROOT/$component/scripts/install.sh"
done
