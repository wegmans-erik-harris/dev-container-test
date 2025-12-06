#!/bin/bash
# Start required MCP servers from /usr/local/bin/mcp.json

set -e

echo "===== MCP Server Startup Debugging ====="
echo "Current user: $(whoami)"
echo "Current PATH: $PATH"
echo "Node version: $(command -v node && node --version 2>/dev/null || echo 'not found')"
echo "NPM version: $(command -v npm && npm --version 2>/dev/null || echo 'not found')"
echo "NPX version: $(command -v npx && npx --version 2>/dev/null || echo 'not found')"
echo "MCP config file: /usr/local/bin/mcp.json"
if [ ! -f "/usr/local/bin/mcp.json" ]; then
  echo "MCP config file not found: /usr/local/bin/mcp.json"
  exit 1
fi
echo "===== MCP config file content ====="
cat /usr/local/bin/mcp.json

echo "===== Starting MCP servers ====="
jq -c '.servers | to_entries[]' "/usr/local/bin/mcp.json" | while read -r SERVER; do
  NAME=$(echo "$SERVER" | jq -r '.key')
  CMD=$(echo "$SERVER" | jq -r '.value.command // empty')
  ARGS=$(echo "$SERVER" | jq -c '.value.args // []')
  echo "---"
  echo "Server: $NAME"
  echo "Command: $CMD"
  echo "Args: $ARGS"
  if [ -n "$CMD" ]; then
    ARGS_ARRAY=()
    for ARG in $(echo "$ARGS" | jq -r '.[]'); do
      ARGS_ARRAY+=("$ARG")
    done
    echo "Executing: $CMD ${ARGS_ARRAY[*]}"
    "$CMD" "${ARGS_ARRAY[@]}" &
    echo "Started MCP server: $NAME"
  else
    echo "Skipping MCP server: $NAME (no command specified)"
  fi
  sleep 2
  docker ps -a || true
  docker logs "$NAME" || true
done
echo "MCP server startup complete."
