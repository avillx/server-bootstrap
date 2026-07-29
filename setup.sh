#!/usr/bin/env bash
set -euo pipefail

REPO="${1:?<owner/repo>}"

WORKDIR="$(mktemp -d)"
[[ "$WORKDIR" == /tmp/* ]] || { echo "mktemp returned unexpected path" >&2; exit 1; }
trap 'rm -rf "$WORKDIR"' EXIT

curl -fsSL "https://github.com/${REPO}/tarball/main" \
  | tar -xz -C "$WORKDIR" --strip-components=1

SCRIPTS=(00-utils 10-packages 20-user-managment 30-ssh 40-firewall 50-fail2ban 60-docker 70-envirement)
for s in "${SCRIPTS[@]}"; do
    source "$WORKDIR/scripts/${s}.sh"
    
done