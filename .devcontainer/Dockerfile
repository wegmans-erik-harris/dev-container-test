FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install required packages
RUN apt-get update && \
    apt-get install -y jq dos2unix && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Note: Scripts will be copied from the cloned workspace via postCreateCommand
# This is a minimal Dockerfile just to set up the base dependencies

