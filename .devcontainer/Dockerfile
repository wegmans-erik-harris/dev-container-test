# Minimal Docker-in-Docker setup
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Install Docker CLI and daemon
RUN apt-get update && \
    apt-get install -y docker.io jq dos2unix && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy MCP startup script and config file, set permissions
COPY start-mcp-servers.sh /usr/local/bin/start-mcp-servers.sh
COPY mcp.json /usr/local/bin/mcp.json
RUN chmod +x /usr/local/bin/start-mcp-servers.sh && dos2unix /usr/local/bin/mcp.json

# Copy troubleshooting script and set permissions
COPY docker-troubleshoot.sh /usr/local/bin/docker-troubleshoot.sh
COPY test-mcp-setup.sh /usr/local/bin/test-mcp-setup.sh
RUN chmod +x /usr/local/bin/docker-troubleshoot.sh /usr/local/bin/test-mcp-setup.sh

# Start Docker daemon by default
CMD ["dockerd-entrypoint.sh"]
