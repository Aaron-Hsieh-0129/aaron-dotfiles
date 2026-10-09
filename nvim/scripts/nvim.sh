#!/bin/sh
# Launch with the private tool environment, without changing the parent shell.
set -eu
tools_root="${XDG_DATA_HOME:-$HOME/.local/share}/aaron-nvim"
PATH="$tools_root/bin:$tools_root/runtime/bin:$PATH"
export PATH
exec nvim "$@"
