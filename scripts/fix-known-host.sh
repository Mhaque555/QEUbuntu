#!/usr/bin/env bash
set -e
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:${SSH_PORT:-2229}" || true
echo "Old SSH host key removed for [localhost]:${SSH_PORT:-2229}"
