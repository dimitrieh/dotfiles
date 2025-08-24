alias shdo="shd open"

shd () {
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

    for basedir ($SELF_HOSTED_PATHS); do
        if [[ -d "$basedir/$project" ]]; then
            $cmd "$basedir/$project"
            return
        fi
    done

    echo "No such self-hosted project '${project}'."
}