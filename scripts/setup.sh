#!/bin/sh
# One-command setup: link this checkout, then install tools without sudo.
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
"$repo_dir/scripts/install.sh"
exec "$repo_dir/scripts/bootstrap.sh" "$@"
