alias pjo="pj open"

pj () {
    emulate -L zsh

    cmd="cd"
    project=$1

    if [[ "open" == "$project" ]]; then
        shift
        project=$*
        cmd=${=EDITOR}
    else
        project=$*
    fi

    for basedir ($PROJECT_PATHS); do
        if [[ -d "$basedir/$project" ]]; then
            $cmd "$basedir/$project"
            return
        fi
    done

    echo "No such project '${project}'."
}
