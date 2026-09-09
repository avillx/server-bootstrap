#!/bin/sh

: "${LIB:=$(dirname "$0")/00-lib.sh}"
. "$LIB"

#################################################
# return config for /root/.profile file
# Arguments:
#   none
# Outputs:
#   profile config
#################################################
root_profile() {
    cat << EOF
export SECONDARY='\e[2;37m'
export RED='\e[0;31m'
export RESET='\e[0m'
export PS1="\${RED}[ROOT]\${SECONDARY} \w # \${RESET}"
EOF
}

#################################################
# return config for ~/.profile file
# Arguments:
#   none
# Outputs:
#   profile config
#################################################
user_profile() {
    cat << EOF
export CYAN='\e[1;34m'
export WHITE='\e[1;37m'
export SECONDARY='\e[2;37m'
export RESET='\e[0m'
export PS1="\${WHITE}\$(whoami)\${SECONDARY}@\${RESET}\${CYAN}\$(hostname) \${SECONDARY}\w » \${RESET}"
EOF
}

#################################################
# return "hello" text for banner
# Arguments:
#   none
# Outputs:
#   banner
#################################################
hello_banner() { # for issue.net
    cat << EOF
 █████               ████  ████          
▒▒███               ▒▒███ ▒▒███          
 ▒███████    ██████  ▒███  ▒███   ██████ 
 ▒███▒▒███  ███▒▒███ ▒███  ▒███  ███▒▒███
 ▒███ ▒███ ▒███████  ▒███  ▒███ ▒███ ▒███
 ▒███ ▒███ ▒███▒▒▒   ▒███  ▒███ ▒███ ▒███
 ████ █████▒▒██████  █████ █████▒▒██████ 
▒▒▒▒ ▒▒▒▒▒  ▒▒▒▒▒▒  ▒▒▒▒▒ ▒▒▒▒▒  ▒▒▒▒▒▒  
EOF
}

#################################################
# Entrypoint. Configure environment
# Arguments:
#   none
# Outputs:
#   none
#################################################
main() {

    root_only

    cleanup "environment"

    info "set host name"

    # hostname
    while true; do
        msg "type name for host: "
        read -r hostname

        if [ -z "$hostname" ]; then
            err "host name must be not empty"
            continue
        fi
        break
    done

    printf '%s\n' "$hostname" > /etc/hostname

    # profiles
    info "set profiles"

    root_profile > "/root/.profile"

    while IFS=: read -r _ _ uid _ _ home _; do
        
        if [ "$uid" -lt 1000 ]; then
            continue
        fi

        [ -d "$home" ] || continue

        user_profile > "$home/.profile"
                    
    done < /etc/passwd

    chsh -s /bin/bash

    # motd
    msg "type message of the day: "
    read -r motd
    printf '%s\n' "$motd" > "/etc/motd"

    # issue.net
    info "set issue.net"
    hello_banner > "/etc/issue.net"

    success "environment is set up"
}
main
