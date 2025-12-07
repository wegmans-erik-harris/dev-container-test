# Custom GitHub Copilot Agents with MCP Servers

This repository demonstrates how to set up custom GitHub Copilot agents that automatically have access to MCP (Model Context Protocol) servers without requiring users to manually configure anything.

## How It Works

### For Users (Zero Configuration Required)

1. Clone this repository
2. Open it in your IDE (VS Code, JetBrains Rider, etc.) with GitHub Copilot installed
3. Open the repository in the devcontainer (your IDE should prompt you)
4. Use the Copilot CLI inside the devcontainer (e.g., `copilot ask "help me"`)

Copilot automatically loads the shared MCP configuration that was copied into `/usr/local/share/copilot/mcp.json`, so every CLI invocation has the repository-defined MCP servers available.

### For Repository Maintainers

The flow now centers on three pieces:

#### 1. Devcontainer Configuration (`.devcontainer/`)

The devcontainer automatically:
- Builds a container with Docker-outside-of-Docker support
- Installs the official GitHub Copilot CLI (`npm install -g @github/copilot`)
- Copies `.devcontainer/mcp.json` into `/usr/local/share/copilot/mcp.json`
- Sets `COPILOT_ADDITIONAL_MCP_CONFIG` so Copilot CLI picks up the MCP definitions automatically

**Key files:**
- `devcontainer.json` - Configures the container and copies the MCP config/utility scripts
- `mcp.json` - Defines MCP servers the repository expects to use
- `copilot-with-mcp.sh` - Optional helper script that runs `copilot --additional-mcp-config /usr/local/share/copilot/mcp.json`

#### 2. MCP Server Configuration (`.devcontainer/mcp.json`)

Same schema as before—each entry declares how to reach or start a server:
```json
{
  "servers": {
    "terraform-mcp-server": {
      "type": "local",
      "command": "docker",
      "args": ["run", "-di", "--rm", "--name", "terraform-mcp-server", "-p", "8080:8080", "hashicorp/terraform-mcp-server"],
      "address": "http://localhost:8080"
    },
    "ado-mcp-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@azure-devops/mcp@next", "wegmans"]
    },
    "azure-mcp-server": {
      "type": "local",
      "command": "npx",
      "args": ["-y", "@azure/mcp@latest", "server", "start"]
    },
    "github-mcp-server": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "requestInit": {
        "headers": {
          "Authorization": "Bearer {{GITHUB_MCP_TOKEN}}"
        }
      }
    }
  }
}
```

#### 3. Custom Copilot Agents (`.github/copilot-agents.json`)

The agents reference those same server keys:
```json
{
  "agents": {
    "terraform-helper": {
      "name": "Terraform Helper",
      "description": "Expert Terraform assistant with MCP server access",
      "tools": [
        { "type": "mcp", "server": "terraform-mcp-server" }
      ],
      "instructions": "You are an expert Terraform assistant..."
    }
  }
}
```

When the user invokes `@terraform-helper`, GitHub Copilot loads the MCP server definitions (via `COPILOT_ADDITIONAL_MCP_CONFIG`) and connects to the referenced server.

## Architecture

```
User clones repo
    ↓
Opens in devcontainer
    ↓
Devcontainer installs Copilot CLI + copies mcp.json → /usr/local/share/copilot/mcp.json
    ↓
COPILOT_ADDITIONAL_MCP_CONFIG is set to that file
    ↓
GitHub Copilot reads .github/copilot-agents.json
    ↓
Custom agents reference MCP server names
    ↓
User runs copilot CLI or @agent in chat
    ↓
Copilot automatically loads the MCP servers from the shared config
```

## Adding New MCP Servers

1. **Edit `.devcontainer/mcp.json`:**
   ```json
   "my-new-server": {
     "type": "local",
     "command": "docker",
     "args": ["run", "--name", "my-new-server", "-p", "9090:9090", "myorg/my-mcp-server"],
     "address": "http://localhost:9090"
   }
   ```

2. **Reference it in `.github/copilot-agents.json`:**
   ```json
   "my-custom-agent": {
     "name": "My Custom Agent",
     "tools": [
       { "type": "mcp", "server": "my-new-server" }
     ],
     "instructions": "..."
   }
   ```

3. **Rebuild the devcontainer** so the updated `mcp.json` is copied into `/usr/local/share/copilot/mcp.json`.

## Troubleshooting

- **Inspect MCP config inside container:**
  ```bash
  cat /usr/local/share/copilot/mcp.json
  ```
- **Verify Copilot CLI sees the config:**
  ```bash
  copilot status
  ```
- **Check Docker-based servers:**
  ```bash
  docker ps -a
  ```

## References
- [Install Copilot CLI](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli)
- [Custom Copilot Agents](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [Extending Copilot Chat with MCP](https://docs.github.com/en/copilot/customizing-copilot/extending-copilot-chat-with-mcp)
- [Model Context Protocol](https://modelcontextprotocol.io/)
