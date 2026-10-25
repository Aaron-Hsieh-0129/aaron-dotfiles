#!/usr/bin/env bash
# Prefer a working tmux on PATH, then the private Conda runtime.
aaron_tmux_select() {
    local candidate
    local launcher="${BASH_SOURCE[0]%/*}/../../bin/tmux"
    while IFS= read -r candidate; do
        [[ "$candidate" -ef "$launcher" ]] && continue
        if "$candidate" -V >/dev/null 2>&1; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done < <(type -aP tmux || true)
    if [[ -x "$1/runtime/bin/tmux" ]] && "$1/runtime/bin/tmux" -V >/dev/null 2>&1; then
        printf '%s/runtime/bin/tmux\n' "$1"
    else
        return 1
    fi
}
