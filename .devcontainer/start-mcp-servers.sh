#!/bin/bash
# Start required MCP servers from .devcontainer/mcp.json and write their info to .mcp_servers.json

set -e

MCP_CONFIG_FILE=".devcontainer/mcp.json"
MCP_SERVERS_FILE="/workspace/.mcp_servers.json"

if [ ! -f "$MCP_CONFIG_FILE" ]; then
  echo "MCP config file not found: $MCP_CONFIG_FILE"
  exit 1
fi

# Parse and start local docker MCP servers
echo "[" > $MCP_SERVERS_FILE
FIRST=1
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
    # Write info to JSON file
    if [ $FIRST -eq 0 ]; then
      echo "," >> $MCP_SERVERS_FILE
    fi
    echo "  {\"name\": \"$NAME\", \"type\": \"docker\", \"address\": \"container://$NAME\"}" >> $MCP_SERVERS_FILE
    FIRST=0
  fi
  # Other types can be handled or logged here
  # For now, just skip
  # TODO: Add support for stdio, remote, etc.
done
echo "]" >> $MCP_SERVERS_FILE

echo "MCP servers started and info written to $MCP_SERVERS_FILE"
