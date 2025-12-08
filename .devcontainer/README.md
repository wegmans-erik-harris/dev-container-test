# MCP Devcontainer

This devcontainer configuration sets up an Ubuntu-based environment with Docker CLI and mounts the host Docker socket. On create it installs the GitHub Copilot CLI and copies the repository's MCP configuration (`.devcontainer/mcp.json`) into `~/.copilot/mcp-config.json`.

## Usage
- Open this folder in any IDE or tool that supports devcontainers.
- Run `copilot --help` or `copilot ask "..."` inside the devcontainer to interact with Copilot; it will automatically load the MCP definitions from `~/.copilot/mcp-config.json`.
- Docker commands continue to work inside the devcontainer thanks to the mounted Docker socket.
- AI assistants and agents can discover available MCP servers by reading `.devcontainer/mcp.json` in the repo or `~/.copilot/mcp-config.json` in the container.

## Security Note
Mounting the Docker socket exposes your host Docker daemon to the devcontainer. Use only in trusted environments.

## Customization
- To add or modify MCP servers, edit `.devcontainer/mcp.json` and rebuild the devcontainer so the updated config is copied into `~/.copilot/mcp-config.json`.
- For more details on how the MCP config is structured, see `MCP_README.md` in the same folder.
