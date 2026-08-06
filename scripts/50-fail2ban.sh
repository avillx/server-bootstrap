#!/bin/sh

. "$(dirname "$0")/00-lib.sh"

#################################################
# Produce fail2ban configuration
# Arguments:
#   ssh port
# Outputs:
#   fail2ban config
#################################################
fail2ban_config() {
    ssh_port="$1"

    cat << EOF
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
backend = systemd

[sshd]
enabled = true
port = ${ssh_port}
EOF
}

#################################################
# Entrypoint install and setting up fail2ban
# Arguments:
#   none
# Outputs:
#   none
#################################################
main() {

    root_only

    cleanup "fail2ban"

    info "install fail2ban"

    if ! apt install -y fail2ban; then
        err "fail2ban install failed"
        exit 1
    fi

    
    if [ -z "$ssh_port" ];then
        ssh_port="$(get_ssh_port)"
        
        if [ -z "$ssh_port" ];then
            err "can't find ssh port"
            msg "type ssh port: "
            read -r ssh_port
        fi
    fi

    info "configuration fail2ban"

    mkdir -p /etc/fail2ban

    CONFIG=/etc/fail2ban/jail.local

    fail2ban_config "$ssh_port" > "$CONFIG"

    if ! systemctl enable --now fail2ban; then
        err "fail2ban start failed"
        exit 1
    fi

    success "fail2ban is set up"
}
main