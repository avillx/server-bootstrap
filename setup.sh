#!/usr/bin/env bash

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
        exec su -c "$0 $*" root
        exit 1
    fi

    set -euo pipefail
  
    # get work directory and ensure it existence
    WORKDIR="$(mktemp -d)"
    
    if [[ "$WORKDIR" == /tmp/* ]] ; then 
        echo "mktemp returned unexpected path" >&2; 
        exit 1
    fi
    
    trap 'rm -rf "$WORKDIR"' EXIT

    # Get other parts of bootstrap
    local repo="${1:?<owner/repo>}"


    # get scripts
    if ! curl -fsSL "https://github.com/${repo}/tarball/main" \
        | tar -xz -C "$WORKDIR" --strip-components=1; then
        echo "problem with repo"
        exit 1
    fi

  # array of script file names
    declare -a SCRIPTS
    SCRIPTS=(
        10-packages 
        20-user-managment 
        30-ssh 40-firewall 
        50-fail2ban 
        60-docker 
        70-envirement
    )
    readonly SCRIPTS

  # run each script
  for script_name in "${SCRIPTS[@]}"; do
        local script_path
        script_path=$(printf "%s/scripts/%s.sh" "$WORKDIR" "$script_name") 
        source "$script_path"
  done

  clear
  printf "//// bootstrap done\n"

}
main "$@"