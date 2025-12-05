# Terraform MCP Devcontainer

This devcontainer configuration sets up an Ubuntu-based environment with Docker CLI and mounts the host Docker socket. On creation, it starts the Terraform MCP server as a Docker container, exposing it on port 8080.

## Usage
- Open this folder in JetBrains Rider or VS Code with devcontainer support.
- The MCP server will be available at `localhost:8080`.
- You can run Docker commands inside the devcontainer to manage other containers.

## Security Note
Mounting the Docker socket exposes your host Docker daemon to the devcontainer. Use only in trusted environments.

