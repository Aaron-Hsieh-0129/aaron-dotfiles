#!/usr/bin/env bash
# Shared option parsing for the repository entry points.
set -euo pipefail
DOTFILES_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
components=(nvim zsh tmux)
component_args=()
parse_options() {
    while (( $# )); do
        case "$1" in
            --only)
                [[ $# -ge 2 ]] || { printf 'Missing component after --only\n' >&2; return 2; }
                case "$2" in nvim|zsh|tmux) components=("$2");; *) printf 'Choose nvim, zsh, or tmux\n' >&2; return 2;; esac
                shift 2 ;;
            --use-existing)
                [[ ${ALLOW_EXISTING:-0} == 1 ]] || { printf '%s is not supported by this command\n' "$1" >&2; return 2; }
                component_args=(--use-existing)
                shift ;;
            --help|-h)
                printf 'Usage: %s [--only nvim|zsh|tmux]' "${0##*/}"
                [[ ${ALLOW_EXISTING:-0} != 1 ]] || printf ' [--use-existing]'
                printf '\nDefault: operate on all components.\n'
                exit 0 ;;
            *) printf 'Unknown argument: %s\n' "$1" >&2; return 2 ;;
        esac
    done
}
