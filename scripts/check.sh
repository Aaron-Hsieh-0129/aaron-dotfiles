#!/usr/bin/env bash
# Verify the selected components using their checks.
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
parse_options "$@"
export AARON_DOTFILES_ROOT="$DOTFILES_ROOT"
for script in "$DOTFILES_ROOT"/scripts/*.sh "$DOTFILES_ROOT"/bin/*; do bash -n "$script"; done
for component in "${components[@]}"; do
    case "$component" in
        nvim)
            "$DOTFILES_ROOT/bin/nvim" --headless '+lua dofile(vim.env.AARON_DOTFILES_ROOT .. "/nvim/scripts/check.lua")' ;;
        zsh) "$DOTFILES_ROOT/zsh/scripts/check.sh" ;;
        tmux) "$DOTFILES_ROOT/tmux/scripts/check.sh" ;;
    esac
done
