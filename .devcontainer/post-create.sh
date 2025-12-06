#!/bin/bash
# Post-create setup script for devcontainer

set -e

echo "======================================"
echo "Devcontainer Post-Create Setup"
echo "======================================"

# Find the workspace
WS=$(pwd)
echo "Current directory: $WS"
echo "Listing contents:"
ls -la

# Check if .devcontainer exists
if [ ! -d ".devcontainer" ]; then
  echo "ERROR: .devcontainer directory not found in $WS"
  echo "Looking for .devcontainer in parent directories..."
  if [ -d "../.devcontainer" ]; then
    WS=$(cd .. && pwd)
    echo "Found .devcontainer in parent: $WS"
  else
    echo "ERROR: Cannot find .devcontainer directory"
    exit 1
  fi
fi

echo ""
echo "Copying scripts from $WS/.devcontainer/ to /usr/local/bin/"
sudo cp "$WS/.devcontainer/start-mcp-servers.sh" /usr/local/bin/start-mcp-servers.sh
sudo cp "$WS/.devcontainer/mcp.json" /usr/local/bin/mcp.json
sudo cp "$WS/.devcontainer/docker-troubleshoot.sh" /usr/local/bin/docker-troubleshoot.sh
sudo cp "$WS/.devcontainer/test-mcp-setup.sh" /usr/local/bin/test-mcp-setup.sh

echo "Setting permissions..."
sudo chmod +x /usr/local/bin/*.sh

echo "Converting line endings..."
sudo dos2unix /usr/local/bin/mcp.json

echo ""
echo "======================================"
echo "Post-Create Setup Complete"
echo "======================================"

