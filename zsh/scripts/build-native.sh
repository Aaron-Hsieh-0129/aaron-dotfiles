#!/usr/bin/env bash
# Fallback for Conda zsh builds that omit ZSH_VERSION (seen on Linux ARM64).
set -euo pipefail
data=$1
build=$(mktemp -d "${TMPDIR:-/tmp}/aaron-zsh-build.XXXXXXXX")
trap 'rm -rf -- "$build"' EXIT
printf 'Building native zsh 5.9 (Conda binary has no version).\n'
curl --fail --location --proto '=https' --proto-redir '=https' --retry 3 --output "$build/zsh.tar.xz" \
    https://cfhcable.dl.sourceforge.net/project/zsh/zsh/5.9/zsh-5.9.tar.xz
checksum=9b8d1ecedd5b5e81fbf1918e876752a7dd948e05c1a0dba10ab863842d45acd5
if command -v sha256sum >/dev/null; then
    actual=$(sha256sum "$build/zsh.tar.xz")
else
    actual=$(shasum -a 256 "$build/zsh.tar.xz")
fi
[[ "${actual%% *}" == "$checksum" ]] || { printf 'zsh source checksum mismatch.\n' >&2; exit 1; }
tar -xJf "$build/zsh.tar.xz" -C "$build"
cd "$build/zsh-5.9"
# Link to the consistent private ncurses; keep these flags local to this build.
CC="${CC:-cc}" CPPFLAGS="-I$data/runtime/include" \
    LDFLAGS="-L$data/runtime/lib -Wl,-rpath,$data/runtime/lib" \
    ./configure --prefix="$data/native" --enable-multibyte --with-tcsetpgrp --disable-pcre --disable-gdbm
make -j2
make install
