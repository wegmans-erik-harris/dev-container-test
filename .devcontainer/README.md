# MCP Devcontainer

This devcontainer configuration sets up an Ubuntu-based environment with Docker CLI and mounts the host Docker socket. On creation, it can automatically start any MCP servers defined in your configuration (see `.devcontainer/mcp.json`).

## Usage
- Open this folder in any IDE or tool that supports devcontainers.
- MCP servers defined in `.devcontainer/mcp.json` will be started automatically if supported (e.g., Docker-based servers).
- You can run Docker commands inside the devcontainer to manage other containers.
- AI assistants and agents can discover available MCP servers by reading the `.devcontainer/mcp.json` file.

## Security Note
Mounting the Docker socket exposes your host Docker daemon to the devcontainer. Use only in trusted environments.

## Customization
- To add or modify MCP servers, edit `.devcontainer/mcp.json` and rebuild the devcontainer.
- For more details, see `MCP_README.md` in the same folder.
