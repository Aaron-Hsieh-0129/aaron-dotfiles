# Aaron's portable interactive zsh entry point.
typeset -g AARON_ZSH_ROOT=${AARON_ZSH_ROOT:-${${(%):-%x}:A:h}}
source "$AARON_ZSH_ROOT/config/zshrc.zsh"

if (( $+functions[aaron_prepend_dir] )) && [[ -d "$HOME/opengrads-hpc-1.0.12-linux-x86_64" ]]; then
    aaron_prepend_dir PATH "$HOME/opengrads-hpc-1.0.12-linux-x86_64"
fi

# Opt in from local.zsh when this machine's external environment is trusted.
if [[ ${AARON_VVM_AUTO_ENV:-0} == 1 && -r "$HOME/libs_VVMex_269/env_setup.sh" ]]; then
    source "$HOME/libs_VVMex_269/env_setup.sh"
fi
export VVM_ROOT="$HOME/VVMex_run"
