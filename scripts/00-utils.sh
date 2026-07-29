#!/bin/sh

GREEN='\e[0;32m'
CYAN='\e[0;36m'
RED='\e[0;31m'
SECOND='\e[2m'
NC='\e[0m'

cleanup() {
    clear
    printf "%s///////// %s%s%s [TOOL] %s\n" \
        "$SECOND" "$NC" "$1" "$CYAN" "$NC"
}

printerror() { 
    printf "\n%s[ERROR]%s %s::: %s :::%s %s" \
         "$RED" "$NC" "$SECOND" "$(date)" "$NC" "$1"
}

printmessage() {
    printf "%s[INFO]%s %s:::%s %s" \
        "$CYAN" "$NC" "$SECOND" "$NC" "$1"
}

printsuccess() {
    printf "%s[SUCCESS]%s %s:::%s %s" \
        "$GREEN" "$NC" "$SECOND" "$NC" "$1"
}

exitwitherror() {
    printerror "$1"
    exit 1
}

check_root() {
    if [[ $EUID -ne 0 ]]; then

        commiterror "This script must be run as root"
    fi
}