#!/bin/sh

: "${LIB:=$(dirname "$0")/00-lib.sh}"
. "$LIB"

#################################################
# Produce config for SSH
# Arguments:
#   port
# Outputs:
#   text of ssh config
#################################################
create_config() {
    port="$1"
    cat << EOF
Port ${port}

# Logging
LogLevel INFO

# Authentication:

LoginGraceTime 2m
PermitRootLogin no
#StrictModes yes
MaxAuthTries 6
MaxSessions 1

PubkeyAuthentication yes
PasswordAuthentication no
#PermitEmptyPasswords no
ChallengeResponseAuthentication no
#UsePAM no

AllowAgentForwarding no
AllowTcpForwarding no
#GatewayPorts no 
PermitTTY yes 
PrintMotd yes
#PrintLastLog yes
MaxStartups 10:30:100
#PermitTunnel no 
#ChrootDirectory none 
Banner /etc/issue.net
AcceptEnv LANG LC_*
EOF
}

#################################################
# Validate port
# Arguments:
#   port
# Outputs:
#   0 - for valid port
#   1 - for invalid port
#################################################
validate_port() {

    port=$1

    if [ -z "$port" ]; then
        err "port must be not empty"
        return 1
    fi

    case "$port" in
        ''|*[!0-9]*)
            err "port must be a number"
            return 1
        ;;
    esac

    if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        err "port must be greater than 1 and less than 65535"
        return 1
    fi

    if [ "$port" -eq 22 ]; then
        err "ssh port 22 is unsafe"
        return 1
    fi

    return 0
}

#################################################
# ensure at least one user has SSH keys
# Arguments:
#   none
# Outputs:
#   0 - when one or more users has ssh keys
#   1 - when no user has SSH keys 
#################################################
ensure_keys() {
    while IFS=: read -r username _ uid _ _ home _; do
        
        # check is real user
        if [ "$uid" -lt 1000 ]; then
            continue
        fi

        # check SSH dir
        if [ ! -d "$home/.ssh" ]; then
            continue
        fi 

        if find "$home/.ssh" -type f >/dev/null 2>&1; then
            info "user ${username} has SSH-keys"
            return 0
        fi
                    
    done < /etc/passwd
    err "has no user with ssh keys"
    return 1
}

#################################################
# Entrypoint. Setup SSH
# Arguments:
#   none
# Outputs:
#   success message 
#################################################
main(){

    root_only

    cleanup "user managment"

    info "install ssh"

    # Install ssh
    if ! apt install -y ssh ; then
        err "error on SSH install"
        exit 1
    fi


    info "ensure access"
    # Ensure SSH keys exist 
    while true; do
        if ensure_keys; then
            break
        fi

        err "At least one user must has ssh keys.\n\
Add keys for any user except \"root\" and then confirm it.\n\
For creating keys use: \"ssh-keygen\"\n
To set keys use: \"ssh-copy-id -i ~/.ssh/<key_name>.pub <user>@<ip>\""

        user_confirm "Do you set keys for ssh for some user?"
    done

    info "ssh port"
    # Validate port
    while true;do
        msg "type port: "
        read -r port
        
        if validate_port "$port"; then
            break
        fi
    done

    # Set config
    config_text=$(create_config "$port")

    # /etc/ssh/sshd_config is ubuntu/debian path
    printf '%s\n' "$config_text" > /etc/ssh/sshd_config

    # service is not restarted. user should do this manually
    # cause next scripts also make changes with restart required
    # full server reboot to apply all changes is better

    info "ssh server is not restarted, you should do this manually."

    success "ssh is set up"
}
main
