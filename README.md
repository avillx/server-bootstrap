# SERVER.bootstrap

Scripts for fast server setup

Run with one command:
```bash
curl -fsSL https://raw.githubusercontent.com/avillx/server-bootstrap/main/99-setup.sh | bash -s -- avillx/server-bootstrap
```

**Scripts:**
- [packages](./10-packages.sh) update and upgrade packages
- [user management](./20-user-managment.sh) set passwords and create user
- [ssh](./30-ssh.sh) setup SSH server
- [firewall](./40-firewall.sh) install and setup firewall
- [fail2ban](./50-fail2ban.sh) install and setup fail2ban
- [docker](./60-docker.sh) install Docker and add user to Docker group
- [environment](./70-envirement.sh) host environment setup (.profile, motd, issue.net, hostname)