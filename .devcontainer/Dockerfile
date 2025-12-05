# Minimal Docker-in-Docker setup
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Install Docker CLI and daemon
RUN apt-get update && \
    apt-get install -y docker.io jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Start Docker daemon by default
CMD ["dockerd-entrypoint.sh"]
