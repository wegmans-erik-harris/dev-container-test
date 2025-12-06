FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install required packages
RUN apt-get update && \
    apt-get install -y jq dos2unix curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js (LTS) and npm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm

# Install GitHub Copilot CLI globally and symlink to /usr/local/bin
RUN npm install -g @githubnext/github-copilot-cli && \
    ln -sf $(npm bin -g)/copilot /usr/local/bin/copilot && \
    copilot --version

# Note: Scripts will be copied from the cloned workspace via postCreateCommand
# This is a minimal Dockerfile just to set up the base dependencies
