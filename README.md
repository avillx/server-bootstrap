# SERVER.bootstrap

Scripts for fast server setup

Run with one command:
```bash
curl -fsSL https://raw.githubusercontent.com/avillx/server-bootstrap/main/setup.sh | bash -s -- avillx/server-bootstrap
```

**Scripts:**
- [packages](./scripts/10-packages.sh) update and upgrade packages
- [user management](./scripts/20-user-managment.sh) set passwords and create user
- [ssh](./scripts/30-ssh.sh) setup SSH server
- [firewall](./scripts/40-firewall.sh) install and setup firewall
- [fail2ban](./scripts/50-fail2ban.sh) install and setup fail2ban
- [docker](./scripts/60-docker.sh) install Docker and add user to Docker group
- [environment](./scripts/70-envirement.sh) host environment setup (.profile, motd, issue.net, hostname)