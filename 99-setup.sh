#!/usr/bin/sh

#################################################
# entrypoint
# Globals:
#   GREEN
#   CYAN
#   RED
#   SECOND
#   NC
# Arguments:
#   github repository e.g. "<owner/repo>""
#################################################
main(){

    # ensure root
    if [ "$(id -u)" -ne 0 ]; then 
        echo "This script must be run as root" 2>&1
        exit 1
    fi

    # get repository argument
    repo=$1
    if [ -z "$repo" ];then
        echo "first argument, want: <owner/repo> has: none"
    fi
  
    # get work directory and ensure it exists
    WORKDIR="$(mktemp -d)"
    trap 'rm -rf "$WORKDIR"' EXIT

    # get all scripts
    if ! curl -fsSL "https://github.com/${repo}/tarball/main" \
        | tar -xz -C "$WORKDIR" --strip-components=1; then
        echo "problem with repo"
        exit 1
    fi

    set -- "10-packages"
    set -- "$@" "20-user-managment"
    set -- "$@" "30-ssh"
    set -- "$@" "40-firewall"
    set -- "$@" "50-fail2ban"
    set -- "$@" "60-docker"
    set -- "$@" "70-envirement"

    for script in "$@"; do
        if ! . "${WORKDIR}/${script}.sh"; then
            err "failed on ${script} script"
            exit 1
        fi             
    done

    printf "//// bootstrap done\n"
}
main "$@"