# QEUbuntu
# Ubuntu VM in Docker (QEMU) — SSH, RDP, Auto-Resize

## Quick Start
```bash
# 1) first run
chmod +x scripts/*.sh ubuntu-vm/entrypoint.sh
./scripts/start.sh

# 2) (optional) if RDP black screen, set up XFCE:
./scripts/setup-xfce.sh
```
1) SSH
```
./scripts/ssh.sh
# or: ssh -p 2229 ubuntu@localhost
```
2) RDP
```
If running locally/VPS: use Windows mstsc → HOST_IP:3389

On Codespaces: prefer web access (noVNC / Guacamole). For noVNC set VNC_ENABLE=1 in .env then ./scripts/restart.sh and open http://localhost:8006
```
3) Change Disk Size
```
./scripts/resize-disk.sh 400G
# boot will auto-run growpart + resize2fs via cloud-init
```
## Troubleshooting
4) SSH host key changed:
```
./scripts/fix-known-host.sh
```
5) Check hostfwd:
```
./scripts/check-forward.sh
```
6) 
