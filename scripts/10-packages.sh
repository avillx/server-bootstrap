#!/bin/sh

. "$(dirname "$0")/00-lib.sh"

#################################################
# Updates actual packages with "apt"
# Globals:
#   none
# Arguments:
#   none
# Outputs:
#   status messages
#################################################
main(){
    cleanup "packages"

    root_only

    info "update"
    if ! apt update ; then
        err "packages update"
        exit 1
    fi

    info "upgrade"
    if ! apt upgrade; then
        err "packages upgrade"
        exit 1
    fi

    success "packages updated"
}

main