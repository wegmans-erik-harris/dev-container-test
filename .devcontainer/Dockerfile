# Minimal Docker-in-Docker setup
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Install Docker CLI and daemon
RUN apt-get update && \
    apt-get install -y docker.io jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy MCP startup script and set permissions
COPY .devcontainer/start-mcp-servers.sh /usr/local/bin/start-mcp-servers.sh
RUN chmod +x /usr/local/bin/start-mcp-servers.sh

# Start Docker daemon by default
CMD ["dockerd-entrypoint.sh"]
