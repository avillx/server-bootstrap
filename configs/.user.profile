export CYAN='\e[1;34m'
export WHITE='\e[1;37m'
export SECONDARY='\e[2;37m'
export RESET='\e[0m'
export PS1="${WHITE}\$(whoami)${SECONDARY}@${RESET}${CYAN}\$(hostname) ${SECONDARY}\w » ${RESET}"