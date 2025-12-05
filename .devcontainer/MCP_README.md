# MCP Server Automation in Devcontainer

When this devcontainer starts, it automatically launches required MCP servers (e.g., Terraform MCP server) in Docker and writes their addresses to `/workspace/.mcp_servers.json`.

## For AI Assistants and Agents
- Discover available MCP servers by reading the JSON file at the path specified in the `MCP_SERVERS` environment variable.
- Example file content:
  ```json
  [
    {
      "name": "terraform-mcp-server",
      "type": "terraform",
      "address": "http://localhost:8080"
    }
  ]
  ```
- If you need more MCP servers, add their Docker run commands to `.devcontainer/start-mcp-servers.sh` and update the JSON output.

## For Users
- MCP servers are started automatically; no manual setup required.
- To customize, edit `.devcontainer/start-mcp-servers.sh`.

## Troubleshooting
- If a server fails to start, check Docker logs with `docker logs <container-name>`.
- Remove or stop servers with `docker stop <container-name>`.

## Extending
- Add new MCP server types by updating the startup script and JSON file.
- AI agents can guide users to add or configure servers as needed.

