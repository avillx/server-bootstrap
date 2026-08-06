#!/bin/sh

. "$(dirname "$0")/00-lib.sh"


#################################################
# Return list of users available for Docker usage
# Arguments:
#   none
# Outputs:
#   list of user_names
#################################################
list_of_users() {
    getent passwd | awk -F: '
    $3 >= 1000 &&
    $3 < 65534 &&
    $7 !~ /(nologin|false)$/ {
        print $1
    }'
}

#################################################
# Attach Docker packages repository to apt
# Arguments:
#   none
# Outputs:
#   0 - on success
#   1 - on error
#################################################
attach_docker_repo() {

    # check os
    os_id=$(. /etc/os-release && echo "$ID")
    if [ "$os_id" != "ubuntu" ] && [ "$os_id" != "debian" ]; then
        err "unsupported os: $os_id"
        exit 1
    fi

    if ! apt install -y ca-certificates; then
        return 1
    fi

    install -m 0755 -d /etc/apt/keyrings
    
    if ! curl -fsSL "https://download.docker.com/linux/$os_id/gpg" \
        -o /etc/apt/keyrings/docker.asc; then
        err "can't docker keys"
        return 1
    fi
    
    chmod a+r /etc/apt/keyrings/docker.asc

    arch=$(dpkg --print-architecture)
    codename=$(. /etc/os-release && echo "$VERSION_CODENAME")

    echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/$os_id $codename stable" \
        > /etc/apt/sources.list.d/docker.list

    if ! apt update; then 
        err "can't update apt"
        return 1 
    fi

    return 0
}

#################################################
# Entrypoint. Install Docker and add user to Docker
# group
# Arguments:
#   none
# Outputs:
#   none
#################################################
main(){

    root_only

    cleanup "docker"

    info "install"

    if ! attach_docker_repo ; then
        err "cant attach docker repo"
        exit 1
    fi

    if ! apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin ; then

        err "install failed"
        exit 1
    fi

    info "user setup"

    while true; do
        
        printf '%s\n\n%s\n%s\n\n' \
            "You must choose a user to grant Docker access." \
            "Available users:" \
            "$(list_of_users)" \
            
        msg "Type user name: "

        read -r user_name

        if ! id "$user_name" >/dev/null 2>&1; then
            err "$(printf "user %s not found" "$user_name")"
            continue
        fi

        if [ "$(id -u "$user_name")" -lt 1000 ]; then
            err "system user is not allowed"
            continue
        fi

        break
    done

    if ! usermod -aG docker "$user_name"; then
        err "user add group failed"
        exit 1
    fi

    info "User ${user_name} must log out and log back in to use Docker without sudo."
    success "docker installed"
}
main