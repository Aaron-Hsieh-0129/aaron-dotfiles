#!/usr/bin/env bash
# Shared by bootstrap, launcher, and checks. Do not accept loader warnings as success.
aaron_zsh_ready() {
    local output
    [[ -x "$1" ]] || return 1
    output=$("$1" -dfc 'autoload -Uz is-at-least; [[ -n $ZSH_VERSION ]] && is-at-least 5.8 && print -r -- AARON_ZSH_READY' 2>&1) || return 1
    [[ "$output" == AARON_ZSH_READY ]]
}

aaron_zsh_select() {
    local candidate
    for candidate in "$1/native/bin/zsh" "$1/runtime/bin/zsh"; do
        if aaron_zsh_ready "$candidate"; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    candidate=$(command -v zsh || true)
    if [[ -n "$candidate" ]] && aaron_zsh_ready "$candidate"; then
        printf '%s\n' "$candidate"
        return 0
    fi
    return 1
}
