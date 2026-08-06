#!/bin/sh

: "${LIB:=$(dirname "$0")/00-lib.sh}"
. "$LIB"

#################################################
# Validate user name: case, empty, and already existing
# Arguments:
#   user name
# Outputs:
#   1 on error
#   0 on success
#################################################
validate_user() {
    user="$1"
    # empty check
    if [ -z "$user" ]; then 
        err "username cannot be empty"
        return 1
    fi

    # lower case check
    if test "$( echo "$user" | tr '[:upper:]' '[:lower:]')" != "$user"; then
        err "user name must be lower case"
        return 1
    fi

    # check existence
    if grep "$user" /etc/passwd; then
        err "User $user already exist"
        return 1
    fi

    return 0
}

#################################################
# Entrypoint. Set root password, create new user with password
# Arguments:
#   none
# Outputs:
#   none
#################################################
main() {

    root_only

    cleanup "user managment"

    ## set root passwd
    info "Set root password "
    if ! passwd; then
        err "Failed to set root password"
        exit 1
    fi
    success "root password updated"

    # get username
    while true ;do
        info "Create a user"
        printf "New user name: "
        read -r user

        if validate_user "$user"; then
            break
        fi
    done

    # create user
    SUDOGROUP="sudo"
    if ! useradd -m -G "$SUDOGROUP" "$user"; then
        err "Failed to create user"
        exit 1
    fi

    ## set passwd
    if ! passwd "$user"; then
        err "Failed to set user password"
        exit 1
    fi
    
    success "user $user has been created"
}
main