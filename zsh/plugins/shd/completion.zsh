_shd () {
    emulate -L zsh

    typeset -a projects
    for basedir ($SELF_HOSTED_PATHS); do
        projects+=(${basedir}/*(/N))
    done

    compadd ${projects:t}
}
compdef _shd shd