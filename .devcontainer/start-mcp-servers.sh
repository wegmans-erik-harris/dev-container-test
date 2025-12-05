#!/bin/bash
# Start required MCP servers from /usr/local/bin/mcp.json

set -e

MCP_CONFIG_FILE="/usr/local/bin/mcp.json"

if [ ! -f "$MCP_CONFIG_FILE" ]; then
  echo "MCP config file not found: $MCP_CONFIG_FILE"
  exit 1
fi

# Parse and start local docker MCP servers
for SERVER in $(jq -c '.servers | to_entries[]' "$MCP_CONFIG_FILE"); do
  NAME=$(echo $SERVER | jq -r '.key')
  TYPE=$(echo $SERVER | jq -r '.value.type')
  CMD=$(echo $SERVER | jq -r '.value.command')
  ARGS=$(echo $SERVER | jq -c '.value.args')
  if [ "$TYPE" = "local" ] && [ "$CMD" = "docker" ]; then
    # Convert ARGS from JSON array to bash array
    ARGS_ARRAY=()
    for ARG in $(echo $ARGS | jq -r '.[]'); do
      ARGS_ARRAY+=("$ARG")
    done
    docker run -d --name "$NAME" "${ARGS_ARRAY[@]:3}"
    echo "Started docker MCP server: $NAME"
  fi
  # Other types can be handled or logged here
  # For now, just skip
  # TODO: Add support for stdio, remote, etc.
done

echo "MCP server startup complete."
