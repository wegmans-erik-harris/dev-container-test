#!/bin/bash
# Start required MCP servers from /usr/local/bin/mcp.json

set -e

MCP_CONFIG_FILE="/usr/local/bin/mcp.json"

if [ ! -f "$MCP_CONFIG_FILE" ]; then
  echo "MCP config file not found: $MCP_CONFIG_FILE"
  exit 1
fi

jq -c '.servers | to_entries[]' "$MCP_CONFIG_FILE" | while read -r SERVER; do
  NAME=$(echo "$SERVER" | jq -r '.key')
  TYPE=$(echo "$SERVER" | jq -r '.value.type // empty')
  CMD=$(echo "$SERVER" | jq -r '.value.command // empty')
  ARGS=$(echo "$SERVER" | jq -c '.value.args // []')
  if [ "$TYPE" = "local" ] && [ -n "$CMD" ]; then
    ARGS_ARRAY=()
    for ARG in $(echo "$ARGS" | jq -r '.[]'); do
      ARGS_ARRAY+=("$ARG")
    done
    echo "Executing: $CMD ${ARGS_ARRAY[*]}"
    "$CMD" "${ARGS_ARRAY[@]}"
    # Diagnostic: check container status
    sleep 2
    docker ps -a
    docker logs "$NAME" || true
    echo "Started MCP server: $NAME"
  else
    echo "Skipping MCP server: $NAME (type: $TYPE, command: $CMD)"
  fi
done

echo "MCP server startup complete."
