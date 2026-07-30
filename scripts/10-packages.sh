#!/bin/sh

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

    msg "update"
    if ! apt-get update ; then
        err "packages update"
        exit 1
    fi

    msg "upgrade"
    if ! apt-get upgrade; then
        err "packages upgrade"
        exit 1
    fi

    success "packages updated"
}

main