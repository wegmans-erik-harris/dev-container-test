#!/bin/bash
# Helper wrapper that injects the shared MCP configuration when invoking Copilot CLI.

set -euo pipefail

CONFIG_PATH="${COPILOT_ADDITIONAL_MCP_CONFIG:-/usr/local/share/copilot/mcp.json}"
if [ ! -f "$CONFIG_PATH" ]; then
  echo "Additional MCP config not found at $CONFIG_PATH" >&2
  exit 1
fi

copilot --additional-mcp-config "$CONFIG_PATH" "$@"

