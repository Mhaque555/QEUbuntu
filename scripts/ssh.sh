#!/usr/bin/env bash
set -e
ssh -o StrictHostKeyChecking=no -p "${SSH_PORT:-2229}" "${USER:-ubuntu}@localhost"
