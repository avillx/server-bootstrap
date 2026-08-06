#!/usr/bin/env bash

GREEN='\e[0;32m'
CYAN='\e[0;36m'
RED='\e[0;31m'
SECOND='\e[2m'
NC='\e[0m'

#################################################
# Clean up output and write tool message
# Globals:
#   SECOND
#   NC
#   CYAN
# Arguments:
#   Tool name
# Outputs:
#   clean + message with tool name
#   e.g. "///////// some utility name [TOOL]"
#################################################
cleanup() {
    clear
    printf "%b///////// %b%s%b [TOOL] %b\n" \
        "$SECOND" "$NC" "$1" "$CYAN" "$NC"
}

#################################################
# Print error message
# Globals:
#   SECOND
#   NC
#   RED
# Arguments:
#   error text
# Outputs:
#   error message in stdout
#   e.g. "[ERROR] ::: some error message"
#################################################
err() { 
    printf "\n%b[ERROR]%b %b:::%b %s\n" \
         "$RED" "$NC" "$SECOND" "$NC" "$1" >&2
}

#################################################
# Print info message
# Globals:
#   SECOND
#   NC
#   CYAN
# Arguments:
#   info text
# Outputs:
#   info message in stdout
# e.g. "[INFO] ::: some info message"
#################################################
info() {
    printf "\n%b[INFO]%b %b:::%b %s\n" \
        "$CYAN" "$NC" "$SECOND" "$NC" "$1"
}

#################################################
# Print direct message to user
# Globals:
#   SECOND
#   NC
#   CYAN
# Arguments:
#   info text
# Outputs:
#   info message in stdout
# e.g. "[!] some message"
#################################################
msg() {
    printf "\n%b[!]%b %s" \
        "$CYAN" "$NC" "$1"
}

#################################################
# Print success message
# Globals:
#   SECOND
#   NC
#   GREEN
# Arguments:
#   success text
# Outputs:
#   success message in stdout
# e.g. "[SUCCESS] ::: some success message"
#################################################
success() {
    printf "\n%b[SUCCESS]%b %b:::%b %s\n" \
        "$GREEN" "$NC" "$SECOND" "$NC" "$1"
}

#################################################
# Ensure shell runned under root
# exit with code 1 when script runned not under root 
# Globals:
#   SECOND
#   NC
#   RED
# Arguments:
#   None
# Outputs:
#   error message in stdout or None
#################################################
root_only() {
    if [ "$(id -u)" -ne 0 ]; then 
        err "This script must be run as root"
        exit 1
    fi
}

#################################################
# Await user confirmation
# Arguments:
#   message for user
# Outputs:
#   message with key for confirmation
#################################################
user_confirm() {
    
    message="$(printf "%s. Press (Y) to confirm: " "$1")"

    while true; do
        msg "$message"

        read -r key

        case "$key" in
            "Y")
                break
            ;;
            "y")
                break
            ;;
            *)
                continue
            ;;
        esac

    done
}

#################################################
# extract port from sshd_config 
# Arguments:
#   none
# Outputs:
#   port
#   none if port is not found
#################################################
get_ssh_port() {
    awk '
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*Port[[:space:]]+/ {
            print $2
            exit
        }
    ' /etc/ssh/sshd_config
}