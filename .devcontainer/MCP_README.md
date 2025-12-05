# MCP Server Automation in Devcontainer

When this devcontainer starts, it automatically launches required MCP servers (e.g., Terraform MCP server) in Docker as defined in `/usr/local/bin/mcp.json`.

## For AI Assistants and Agents
- Discover available MCP servers by reading the JSON file at `/usr/local/bin/mcp.json`.
- This file follows the standard MCP server configuration format:
  ```json
  {
    "servers": {
      "terraform-mcp-server": {
        "type": "local",
        "command": "docker",
        "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server"]
      }
    }
  }
  ```
  *Note: JSON does not support comments. To add more servers, add new entries to the "servers" object as shown above*
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
