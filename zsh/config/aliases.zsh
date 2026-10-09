# Common aliases and optional integrations.
alias ll='ls -lh'
alias la='ls -A'
alias l='ls -CF'
alias zshconfig='${EDITOR:-vi} "$AARON_ZSH_ROOT/config/zshrc.zsh"'
# Use the Neovim component in this combined checkout.
export AARON_DOTFILES_ROOT="${AARON_ZSH_ROOT:A:h}"
if [[ -x "$AARON_DOTFILES_ROOT/bin/nvim" ]]; then
    export EDITOR="$AARON_DOTFILES_ROOT/bin/nvim" VISUAL="$AARON_DOTFILES_ROOT/bin/nvim"
elif (( $+commands[nvim] )); then
    export EDITOR=nvim VISUAL=nvim
elif (( $+commands[vim] )); then
    export EDITOR=vim VISUAL=vim
fi
nvim() {
    local launcher=${AARON_NVIM_LAUNCHER:-$AARON_DOTFILES_ROOT/nvim/scripts/nvim.sh}
    if [[ ! -x "$launcher" ]]; then
        launcher="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/scripts/nvim.sh"
    fi
    if [[ -x "$launcher" ]]; then "$launcher" "$@"; else command nvim "$@"; fi
}
# Cluster aliases use the current user, and are only defined if supported.
if (( $+commands[squeue] )); then
    q() { squeue -u "${USER:-$(id -un)}" --format='%.18i %.9P %.20j %.10u %.3t %.25S %.15L %.10C %.6D %.20R' "$@"; }
    alias sqp='squeue -o "%.28j %.12u" -p'
fi
(( ! $+commands[sinfo] )) || alias si='sinfo -s'
(( ! $+commands[sbatch] )) || alias sb='sbatch'
(( ! $+commands[scontrol] )) || { alias sj='scontrol show job'; alias sp='scontrol show partition'; }
if [[ -x /usr/lpp/mmfs/bin/mmlsquota ]]; then
    qu() { /usr/lpp/mmfs/bin/mmlsquota -u "$USER" --block-size auto fs01 fs02 "$@"; }
fi
(( ! $+commands[sacctmgr] )) || alias no='sacctmgr show qos -o format=name,MinTRES%28,MaxTRES%28,MaxJobsPU | grep "ct"'
vvmex() { [[ -n ${VVM_ROOT:-} ]] && cd "$VVM_ROOT"; }
vvm() { [[ -n ${VVM_GPU_ROOT:-} ]] && cd "$VVM_GPU_ROOT"; }
vvm-env() { source "$AARON_ZSH_ROOT/profiles/nvhpc.zsh"; }
