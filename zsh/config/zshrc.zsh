# Machine settings load before tools; syntax highlighting loads last.
[[ -o interactive ]] || return
# Avoid duplicate plugin hooks if .zshrc is sourced twice.
[[ ${_AARON_ZSH_LOADED:-} == 1 ]] && return
typeset -g _AARON_ZSH_LOADED=1

source "$AARON_ZSH_ROOT/config/paths.zsh"
typeset -g AARON_ZSH_DATA=${AARON_ZSH_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/aaron-zsh}
typeset -g AARON_ZSH_LOCAL_FILE=${AARON_ZSH_LOCAL_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/aaron-zsh/local.zsh}
if [[ ${AARON_ZSH_LOAD_LOCAL:-1} != 0 ]]; then
    [[ ! -r "$AARON_ZSH_LOCAL_FILE" ]] || source "$AARON_ZSH_LOCAL_FILE"
    [[ ! -r "$AARON_ZSH_ROOT/local.zsh" ]] || source "$AARON_ZSH_ROOT/local.zsh"
fi
aaron_prepend_dir PATH "$AARON_ZSH_DATA/runtime/bin"
aaron_prepend_dir PATH "$AARON_ZSH_DATA/native/bin"

aaron_prepend_dir PATH "$HOME/.local/bin"
aaron_prepend_dir PATH "$HOME/.npm-global/bin"
source "$AARON_ZSH_ROOT/config/conda.zsh"

# Make installed completion definitions visible before compinit/Oh My Zsh.
[[ ! -d "$AARON_ZSH_DATA/plugins/zsh-completions/src" ]] || fpath=("$AARON_ZSH_DATA/plugins/zsh-completions/src" $fpath)
typeset -U fpath
export ZSH="$AARON_ZSH_DATA/plugins/oh-my-zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/aaron-zsh/oh-my-zsh"
mkdir -p "$ZSH_CACHE_DIR"
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/aaron-zsh/zcompdump-${ZSH_VERSION}"
ZSH_THEME=""
plugins=(git)
zstyle ':omz:update' mode disabled
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
else
    autoload -Uz compinit
    compinit -i -d "$ZSH_COMPDUMP"
    PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f %# '
fi

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/aaron-zsh/history"
# History can contain credentials; create it privately even with a permissive umask.
(umask 077; mkdir -p "${HISTFILE:h}"; touch "$HISTFILE")
chmod 600 "$HISTFILE"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_IGNORE_SPACE
bindkey -e
source "$AARON_ZSH_ROOT/config/aliases.zsh"

[[ ! -r "$AARON_ZSH_DATA/plugins/powerlevel10k/powerlevel10k.zsh-theme" ]] || source "$AARON_ZSH_DATA/plugins/powerlevel10k/powerlevel10k.zsh-theme"
source "$AARON_ZSH_ROOT/config/p10k.zsh"
for _aaron_plugin in zsh-autosuggestions zsh-history-substring-search; do
    [[ ! -r "$AARON_ZSH_DATA/plugins/$_aaron_plugin/$_aaron_plugin.zsh" ]] || source "$AARON_ZSH_DATA/plugins/$_aaron_plugin/$_aaron_plugin.zsh"
done
unset _aaron_plugin
[[ ! -r "$AARON_ZSH_DATA/plugins/zsh-autopair/autopair.zsh" ]] || source "$AARON_ZSH_DATA/plugins/zsh-autopair/autopair.zsh"
if (( $+functions[history-substring-search-up] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[OA' history-substring-search-up
    bindkey '^[OB' history-substring-search-down
fi
# This plugin must load after completion and other ZLE widgets.
[[ ! -r "$AARON_ZSH_DATA/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] || source "$AARON_ZSH_DATA/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
