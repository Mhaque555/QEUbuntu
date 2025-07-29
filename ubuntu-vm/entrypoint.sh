#!/usr/bin/env bash
set -euo pipefail

# ----- Env (defaults) -----
DISK_SIZE="${DISK_SIZE:-64G}"
RAM_SIZE="${RAM_SIZE:-2048}"
CPU_CORES="${CPU_CORES:-2}"
SSH_PORT="${SSH_PORT:-2222}"
USER="${USER:-ubuntu}"
PASSWORD="${PASSWORD:-ubuntu}"
AUTHORIZED_KEY="${AUTHORIZED_KEY:-}"
VNC_ENABLE="${VNC_ENABLE:-0}"

VM_DIR="/vm"
BASE_IMG="$VM_DIR/ubuntu-base.qcow2"
DISK_IMG="$VM_DIR/ubuntu-disk.qcow2"
SEED_ISO="$VM_DIR/seed.iso"

# Ubuntu 24.04 LTS (Noble)
UBUNTU_CLOUD_IMG_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"

mkdir -p "$VM_DIR"

echo "[*] Downloading Ubuntu cloud image (if missing)..."
if [ ! -f "$BASE_IMG" ]; then
  curl -fL "$UBUNTU_CLOUD_IMG_URL" -o "$BASE_IMG"
fi

echo "[*] Preparing VM disk..."
if [ ! -f "$DISK_IMG" ]; then
  cp "$BASE_IMG" "$DISK_IMG"
fi
# Grow to requested size on every boot (shrink ignored safely)
qemu-img resize -f qcow2 "$DISK_IMG" "$DISK_SIZE" || true

echo "[*] Creating cloud-init seed ISO..."
META_DATA="$VM_DIR/meta-data"
USER_DATA="$VM_DIR/user-data"

# Include DISK_SIZE in instance-id to force cloud-init rerun when size changes
cat > "$META_DATA" <<EOF
instance-id: iid-ubuntu-vm-${DISK_SIZE}
local-hostname: ubuntu-vm
EOF

SSH_BLOCK=""
if [ -n "$AUTHORIZED_KEY" ]; then
  SSH_BLOCK="ssh_authorized_keys:\n  - ${AUTHORIZED_KEY}"
fi

cat > "$USER_DATA" <<EOF
#cloud-config
users:
  - name: ${USER}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    ${SSH_BLOCK}
ssh_pwauth: true
chpasswd:
  list: |
    ${USER}:${PASSWORD}
  expire: false
package_update: true
runcmd:
  - [ sh, -c, "which growpart || (apt-get update && apt-get install -y cloud-guest-utils)" ]
  - [ sh, -c, "growpart /dev/vda 1 || true" ]
  - [ sh, -c, "resize2fs /dev/vda1 || true" ]
EOF

genisoimage -quiet -output "$SEED_ISO" -volid cidata -joliet -rock "$USER_DATA" "$META_DATA" || true

echo "[*] Building QEMU args..."
QEMU_ARGS=(
  -machine accel=tcg
  -cpu max
  -smp "${CPU_CORES}"
  -m "${RAM_SIZE}"
  -drive if=virtio,file="$DISK_IMG",format=qcow2
  -cdrom "$SEED_ISO"
  -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22,hostfwd=tcp::3389-:3389
  -device virtio-net-pci,netdev=net0
)

if [ "$VNC_ENABLE" = "1" ]; then
  # QEMU VNC backend + better pointer
  QEMU_ARGS+=( -vnc :0 )
  QEMU_ARGS+=( -vga std )
  QEMU_ARGS+=( -device usb-tablet )
  # noVNC proxy (web UI: :8006)
  if [ ! -d "/opt/noVNC" ]; then
    git clone --depth 1 https://github.com/novnc/noVNC /opt/noVNC
  fi
  /opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 8006 &
else
  QEMU_ARGS+=( -nographic )
fi

echo "[*] Starting QEMU..."
exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
