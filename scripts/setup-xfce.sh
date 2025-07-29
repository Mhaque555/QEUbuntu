#!/usr/bin/env bash
set -e
PORT="${SSH_PORT:-2229}"
USER_NAME="${USER:-ubuntu}"
ssh -o StrictHostKeyChecking=no -p "$PORT" "${USER_NAME}@localhost" <<'EOS'
set -e
sudo apt-get update
sudo apt-get install -y xfce4 xfce4-goodies xrdp xorgxrdp dbus-x11
echo "startxfce4" > ~/.xsession
chmod 644 ~/.xsession
sudo cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak || true
sudo bash -lc 'cat >/etc/xrdp/startwm.sh' <<'EOT'
#!/bin/sh
[ -r /etc/profile ] && . /etc/profile
[ -r ~/.profile ] && . ~/.profile
startxfce4
EOT
sudo chmod +x /etc/xrdp/startwm.sh
sudo systemctl enable xrdp
sudo systemctl restart xrdp
echo "XFCE + XRDP ready."
EOS
