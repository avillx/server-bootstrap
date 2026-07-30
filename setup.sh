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
    printf "%s///////// %s%s%s [TOOL] %s\n" \
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
    printf "\n%s[ERROR]%s %s:::%s %s" \
         "$RED" "$NC" "$SECOND" "$NC" "$1"
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
msg() {
    printf "%s[INFO]%s %s:::%s %s" \
        "$CYAN" "$NC" "$SECOND" "$NC" "$1"
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
    printf "%s[SUCCESS]%s %s:::%s %s" \
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
check_root() {
    if [[ $EUID -ne 0 ]]; then
        err "This script must be run as root"
        exit 1
    fi
}

#################################################
# entrypoint
# Globals:
#   GREEN
#   CYAN
#   RED
#   SECOND
#   NC
# Arguments:
#   github repository e.g. "<owner/repo>""
#################################################
main(){
  set -euo pipefail
  
  # get work direcry and ensure it existence
  WORKDIR="$(mktemp -d)"
  [[ "$WORKDIR" == /tmp/* ]] || { echo "mktemp returned unexpected path" >&2; exit 1; }
  trap 'rm -rf "$WORKDIR"' EXIT

  # Get other parts of bootstrap
  local repo="${1:?<owner/repo>}"
  curl -fsSL "https://github.com/${repo}/tarball/main" \
    | tar -xz -C "$WORKDIR" --strip-components=1


  # array of script file names
  declare -a SCRIPTS
  SCRIPTS=(
    00-util
    10-packages 
    20-user-managment 
    30-ssh 40-firewall 
    50-fail2ban 
    60-docker 
    70-envirement
  )
  readonly SCRIPTS

  # run each script
  local script_name
  for script_name in "${SCRIPTS[@]}"; do
      source "$WORKDIR/scripts/${script_name}.sh"  
  done
}
main "$@"