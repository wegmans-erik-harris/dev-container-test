# MCP Server Automation in Devcontainer

When this devcontainer starts, it automatically launches required MCP servers (e.g., Terraform MCP server) in Docker as defined in `/usr/local/bin/mcp.json`.

## For AI Assistants and Agents
- AI assistants can discover available MCP servers by reading `/workspace/.devcontainer/mcp.json` and using the `address` field for each server.
- For Docker-based MCP servers, ensure the port is published and the address is reachable from the devcontainer.
- The AI assistant can use this file directly for MCP server discovery and configuration.

## For Users
- MCP servers are started automatically; no manual setup required.
- To customize, edit `.devcontainer/mcp.json` in your project and rebuild the devcontainer.

## Troubleshooting
- If a server fails to start, check Docker logs with `docker logs <container-name>`.
- Remove or stop servers with `docker stop <container-name>`.

## Extending
- Add new MCP server types by updating the JSON file and, if needed, the startup script.
- AI agents can guide users to add or configure servers as needed.
