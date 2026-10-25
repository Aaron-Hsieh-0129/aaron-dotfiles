# Aaron's portable interactive zsh entry point.
typeset -g AARON_ZSH_ROOT=${AARON_ZSH_ROOT:-${${(%):-%x}:A:h}}
source "$AARON_ZSH_ROOT/config/zshrc.zsh"

export PATH="$HOME/opengrads-hpc-1.0.12-linux-x86_64:$PATH"

source "$HOME/libs_VVMex_269/env_setup.sh"
export VVM_ROOT="$HOME/VVMex_run"
