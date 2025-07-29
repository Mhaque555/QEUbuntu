#!/usr/bin/env bash
set -e
chmod +x ubuntu-vm/entrypoint.sh
docker compose up -d --build
docker ps --format '{{.Names}}\t{{.Ports}}'
echo
echo "→ SSH: ssh -p ${SSH_PORT:-2229} ${USER:-ubuntu}@localhost"
echo "→ RDP: ${RDP_PORT:-3389} (mstsc HOST_IP:${RDP_PORT:-3389})"
echo "→ noVNC: http://localhost:8006 (if VNC_ENABLE=1)"
