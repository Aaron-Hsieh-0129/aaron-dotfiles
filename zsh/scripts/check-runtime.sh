#!/usr/bin/env bash
# Regression: loader warnings can accompany a successful exit status.
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/runtime.sh"
fixture=$(mktemp -d "${TMPDIR:-/tmp}/aaron-zsh-runtime-check.XXXXXXXX")
trap 'rm -rf -- "$fixture"' EXIT
mkdir -p "$fixture/path" "$fixture/data/runtime/bin" "$fixture/data/native/bin"
cat > "$fixture/healthy" <<'SH'
#!/bin/bash
printf 'AARON_ZSH_READY\n'
SH
cat > "$fixture/warning" <<'SH'
#!/bin/bash
printf 'zsh: libtinfow.so.6: no version information available\n' >&2
printf 'AARON_ZSH_READY\n'
SH
cat > "$fixture/failed" <<'SH'
#!/bin/bash
printf 'AARON_ZSH_READY\n'
exit 1
SH
cat > "$fixture/versionless" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$fixture/healthy" "$fixture/warning" "$fixture/failed" "$fixture/versionless"
aaron_zsh_ready "$fixture/healthy"
for candidate in warning failed versionless missing; do
    if aaron_zsh_ready "$fixture/$candidate"; then
        printf 'FAIL: accepted %s shell\n' "$candidate" >&2
        exit 1
    fi
done
ln -s "$fixture/healthy" "$fixture/path/zsh"
ln -s "$fixture/healthy" "$fixture/data/runtime/bin/zsh"
ln -s "$fixture/healthy" "$fixture/data/native/bin/zsh"
[[ $(PATH="$fixture/path" aaron_zsh_select "$fixture/data") == "$fixture/data/native/bin/zsh" ]]
rm "$fixture/data/native/bin/zsh"
[[ $(PATH="$fixture/path" aaron_zsh_select "$fixture/data") == "$fixture/data/runtime/bin/zsh" ]]
rm "$fixture/data/runtime/bin/zsh"
ln -s "$fixture/warning" "$fixture/data/runtime/bin/zsh"
[[ $(PATH="$fixture/path" aaron_zsh_select "$fixture/data") == "$fixture/path/zsh" ]]
rm "$fixture/path/zsh"
ln -s "$fixture/warning" "$fixture/path/zsh"
if PATH="$fixture/path" aaron_zsh_select "$fixture/data"; then
    printf 'FAIL: accepted warning-emitting shells\n' >&2
    exit 1
fi
printf 'PASS: runtime validation and shell selection\n'
