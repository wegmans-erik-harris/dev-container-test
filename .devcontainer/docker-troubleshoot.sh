#!/bin/bash
# Troubleshooting script for Docker socket permission issues in a devcontainer

set -e

echo "===== Current User Info ====="
whoami
id

echo "===== Docker Socket Info ====="
ls -l /var/run/docker.sock || echo "/var/run/docker.sock not found"

echo "===== Docker Group Info ====="
grep docker /etc/group || echo "docker group not found"

echo "===== User's Groups ====="
groups

echo "===== Docker Version ====="
docker --version || echo "docker not installed or not in PATH"

echo "===== Docker Info ====="
docker info || echo "Cannot access Docker info (likely permission issue)"

echo "===== Test Docker Run ====="
docker run --rm hello-world || echo "Cannot run Docker container (likely permission issue)"

echo "===== Environment Variables ====="
printenv | grep -E 'USER|USERNAME|HOME|PATH'

echo "===== End of Troubleshooting ====="

