#!/usr/bin/env bash
set -euo pipefail
scripts=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
"$scripts/bootstrap.sh" "$@"
"$scripts/install.sh"
