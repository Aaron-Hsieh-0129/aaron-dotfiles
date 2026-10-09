#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
data="${AARON_ZSH_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/aaron-zsh}"
zsh_exe=$(command -v zsh || true)
[[ ! -x "$data/runtime/bin/zsh" ]] || zsh_exe="$data/runtime/bin/zsh"
[[ -n "$zsh_exe" ]] || { printf 'Run bootstrap first.\n' >&2; exit 1; }
for script in "$repo"/scripts/*.sh; do bash -n "$script"; done
for config in "$repo/.zshrc" "$repo"/config/*.zsh "$repo"/profiles/*.zsh "$repo/local.example.zsh"; do "$zsh_exe" -fn "$config"; done
while IFS=$'\t' read -r name url commit; do
    [[ -n "$name" && "$name" != \#* ]] || continue
    actual=$(git -C "$data/plugins/$name" rev-parse HEAD)
    [[ "$actual" == "$commit" ]] || { printf 'Plugin mismatch: %s\n' "$name" >&2; exit 1; }
done < "$repo/plugins.lock.tsv"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/aaron-zsh-check.XXXXXXXX")
trap 'rm -rf -- "$test_root"' EXIT
mkdir -p "$test_root/startup" "$test_root/state" "$test_root/config" "$test_root/cache"
printf '# previous configuration\n' > "$test_root/startup/.zshrc"
env ZDOTDIR="$test_root/startup" XDG_STATE_HOME="$test_root/state" "$repo/scripts/install.sh"
[[ "$test_root/startup/.zshrc" -ef "$repo/.zshrc" ]]
backup=$(find "$test_root/state/aaron-zsh/backups" -name .zshrc -type f)
[[ -n "$backup" ]] && cmp -s "$backup" <(printf '# previous configuration\n')
env ZDOTDIR="$test_root/startup" XDG_STATE_HOME="$test_root/state" "$repo/scripts/install.sh"
env ZDOTDIR="$test_root/startup" AARON_ZSH_DATA="$data" AARON_ZSH_CONDA=0 AARON_ZSH_LOAD_LOCAL=0 AARON_ZSH_LOCAL_FILE="$test_root/missing-local.zsh" XDG_CONFIG_HOME="$test_root/config" XDG_STATE_HOME="$test_root/state" XDG_CACHE_HOME="$test_root/cache" "$zsh_exe" -i -c '
    (( $+functions[p10k] )) || exit 1
    (( $+functions[_zsh_autosuggest_start] )) || exit 1
    (( $+functions[history-substring-search-up] )) || exit 1
    (( $+functions[_zsh_highlight] )) || exit 1
    (( $+functions[autopair-init] )) || exit 1
    (( $+functions[vvm-env] )) || exit 1
    (( $+functions[nvim] )) || exit 1
    typeset -a before=($path)
    aaron_prepend_dir PATH "$AARON_ZSH_ROOT"
    aaron_prepend_dir PATH "$AARON_ZSH_ROOT"
    [[ ${#${(M)path:#$AARON_ZSH_ROOT}} == 1 ]] || exit 1
    unset _AARON_TEST_PATH
    aaron_prepend_dir _AARON_TEST_PATH "$AARON_ZSH_ROOT"
    aaron_prepend_dir _AARON_TEST_PATH "$AARON_ZSH_ROOT"
    [[ "$_AARON_TEST_PATH" == "$AARON_ZSH_ROOT" ]] || exit 1
    source "$ZDOTDIR/.zshrc"
    print "PASS: plugins, prompt, aliases, repeated startup, and path deduplication"
'
printf 'PASS: syntax and installer backup/idempotence\n'
