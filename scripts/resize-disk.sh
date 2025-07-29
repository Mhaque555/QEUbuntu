#!/usr/bin/env bash
set -e
SIZE="${1:-}"
if [ -z "$SIZE" ]; then
  echo "Usage: $0 <NEW_SIZE>   e.g.  $0 400G"
  exit 1
fi
# Update DISK_SIZE in .env
if grep -q '^DISK_SIZE=' .env; then
  sed -i "s/^DISK_SIZE=.*/DISK_SIZE=${SIZE}/" .env
else
  echo "DISK_SIZE=${SIZE}" >> .env
fi
echo "DISK_SIZE updated to ${SIZE}."
docker compose down
docker compose up -d --build
echo "Rebooting VM will auto-grow partition via cloud-init..."
