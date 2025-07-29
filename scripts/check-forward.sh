#!/usr/bin/env bash
set -e
docker exec -it ubuntu-vm bash -lc "ps aux | grep qemu-system | grep -v grep | sed 's/ -/\n -/g' | grep hostfwd"
