# Aaron's portable interactive zsh entry point.
typeset -g AARON_ZSH_ROOT=${AARON_ZSH_ROOT:-${${(%):-%x}:A:h}}
source "$AARON_ZSH_ROOT/config/zshrc.zsh"
