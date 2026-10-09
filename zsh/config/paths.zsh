# Prepend existing directories once, without empty path entries.
aaron_prepend_dir() {
    local variable=$1 directory=$2 current
    [[ -d "$directory" ]] || return 0
    current=${(P)variable}
    local -a entries
    entries=("$directory" ${(@s/:/)current})
    entries=(${entries:#})
    typeset -U entries
    export "$variable=${(j/:/)entries}"
}
