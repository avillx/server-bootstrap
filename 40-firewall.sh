#!/bin/sh

: "${LIB:=$(dirname "$0")/00-lib.sh}"
. "$LIB"

#################################################
# Produce config for iptables ipv4
# Arguments:
#   ssh port
# Outputs:
#   text of iptables config
#################################################
ipv4_iptables_config() {
    ssh_port="$1"
    cat << EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p tcp --dport ${ssh_port} -j ACCEPT
-A INPUT -p icmp -j ACCEPT
COMMIT
EOF
}

#################################################
# Produce config for iptables ipv6
# Arguments:
#   none
# Outputs:
#   text of iptables config
#################################################
ipv6_iptables_config() {
    cat << EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
COMMIT
EOF
}

#################################################
# Entrypoint. Install and set up iptables with
# persistent config
# Arguments:
#   none
# Outputs:
#   none
#################################################
main() {
    
    root_only

    cleanup "firewall"

    info "install iptables"

    # auto choice for visual selector 
    echo "iptables-persistent \
iptables-persistent/autosave_v4 boolean false" | debconf-set-selections

    echo "iptables-persistent \
iptables-persistent/autosave_v6 boolean false" | debconf-set-selections
    
    if ! apt install -y iptables netfilter-persistent iptables-persistent;then 
        err "iptables install failed"
        exit 1
    fi

    info "configuring iptables"

    if [ -z "$ssh_port" ];then
        ssh_port="$(get_ssh_port)"
        
        if [ -z "$ssh_port" ];then
            err "can't find ssh port"
            msg "type ssh port: "
            read -r ssh_port
        fi
    fi

    RULES_V4=/etc/iptables/rules.v4
    RULES_V6=/etc/iptables/rules.v6

    # write persistent rule files
    mkdir -p /etc/iptables
    ipv4_iptables_config "$ssh_port" > "$RULES_V4"
    ipv6_iptables_config > "$RULES_V6"

    # validation (iptables-restore --test) is unnecessary for this simple config
    
    # apply
    if ! iptables-restore < "$RULES_V4"; then
        err "ipv4 config restore has errors"
        exit 1
    fi

    if ! ip6tables-restore < "$RULES_V6"; then
        err "ipv6 config restore has errors"
        exit 1
    fi

    # enable daemon
    if ! systemctl enable --now netfilter-persistent; then
        err "failed to enable netfilter-persistent"
        exit 1
    fi

    success "iptables configured"
}
main