# Use the zsh hook, without injecting Conda's libraries into every program.
if [[ ${AARON_ZSH_CONDA:-1} != 0 ]] && (( ! $+functions[conda] )); then
    typeset _aaron_conda=${AARON_CONDA_EXE:-${CONDA_EXE:-}}
    if [[ ! -x "$_aaron_conda" ]]; then
        for _aaron_candidate in "$HOME/miniforge3/bin/conda" "$HOME/miniconda3/bin/conda" "$HOME/mambaforge/bin/conda"; do
            if [[ -x "$_aaron_candidate" ]]; then
                _aaron_conda=$_aaron_candidate
                break
            fi
        done
    fi
    if [[ -x "$_aaron_conda" ]]; then
        _aaron_hook=$(CONDA_AUTO_ACTIVATE_BASE=false "$_aaron_conda" shell.zsh hook 2>/dev/null)
        if [[ $? == 0 ]]; then eval "$_aaron_hook"; fi
    fi
    unset _aaron_conda _aaron_candidate _aaron_hook
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
