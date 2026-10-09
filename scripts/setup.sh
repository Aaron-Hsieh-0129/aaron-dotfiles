#!/usr/bin/env bash
# Install dependencies and link the selected components without sudo.
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
ALLOW_EXISTING=1
parse_options "$@"
for component in "${components[@]}"; do
    "$DOTFILES_ROOT/$component/scripts/setup.sh" "${component_args[@]}"
done
