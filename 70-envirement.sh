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
CYAN='\[\e[1;34m\]'
WHITE='\[\e[1;37m\]'
SECONDARY='\[\e[2;37m\]'
RESET='\[\e[0m\]'
PS1="${WHITE}\u${SECONDARY}@${RESET}${CYAN}\h ${SECONDARY}\w » ${RESET}"
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

    # set /bin/bash for all user as default
    while IFS=: read -r user _ uid _ _ _ _; do
        [ "$uid" -ge 1000 ] && usermod -s /bin/bash "$user"
    done < /etc/passwd

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
