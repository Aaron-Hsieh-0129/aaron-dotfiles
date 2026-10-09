#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
data="${AARON_ZSH_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/aaron-zsh}"
bash "$repo/scripts/check-runtime.sh"
source "$repo/scripts/runtime.sh"
zsh_exe=$(aaron_zsh_select "$data") || { printf 'Run bootstrap first to install or repair zsh.\n' >&2; exit 1; }
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
# Reproduce installation from the wrapper, including a symlinked ZDOTDIR.
mkdir -p "$test_root/checkout/scripts"
cp "$repo/scripts/install.sh" "$test_root/checkout/scripts/install.sh"
cp "$repo/.zshrc" "$test_root/checkout/.zshrc"
ln -s "$test_root/checkout" "$test_root/checkout-alias"
for directory in "$test_root/checkout" "$test_root/checkout-alias"; do
    env ZDOTDIR="$directory" XDG_STATE_HOME="$test_root/state" bash "$test_root/checkout/scripts/install.sh"
    [[ -f "$test_root/checkout/.zshrc" && ! -L "$test_root/checkout/.zshrc" ]]
    cmp -s "$repo/.zshrc" "$test_root/checkout/.zshrc"
done
rm "$test_root/checkout/.zshrc"
ln -s "$test_root/checkout/.zshrc" "$test_root/checkout/.zshrc"
if env ZDOTDIR="$test_root/invalid-target" bash "$test_root/checkout/scripts/install.sh" > "$test_root/invalid-source.log" 2>&1; then
    printf 'FAIL: installer accepted a self-linked source\n' >&2
    exit 1
fi
[[ ! -e "$test_root/invalid-target" ]]
printf 'PASS: installer protects checkout startup file\n'
printf '# previous configuration\n' > "$test_root/startup/.zshrc"
env ZDOTDIR="$test_root/startup" XDG_STATE_HOME="$test_root/state" "$repo/scripts/install.sh"
[[ "$test_root/startup/.zshrc" -ef "$repo/.zshrc" ]]
backup=$(find "$test_root/state/aaron-zsh/backups" -name .zshrc -type f)
[[ -n "$backup" ]] && cmp -s "$backup" <(printf '# previous configuration\n')
env ZDOTDIR="$test_root/startup" XDG_STATE_HOME="$test_root/state" "$repo/scripts/install.sh"
env ZDOTDIR="$test_root/startup" AARON_ZSH_DATA="$data" AARON_ZSH_CONDA=0 AARON_ZSH_LOAD_LOCAL=0 AARON_ZSH_LOCAL_FILE="$test_root/missing-local.zsh" XDG_CONFIG_HOME="$test_root/config" XDG_STATE_HOME="$test_root/state" XDG_CACHE_HOME="$test_root/cache" "$repo/scripts/zsh.sh" -i -c '
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
