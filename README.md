# Custom GitHub Copilot Agents with MCP Servers

This repository demonstrates how to set up custom GitHub Copilot agents that automatically have access to MCP (Model Context Protocol) servers without requiring users to manually configure anything.

## How It Works

### For Users (Zero Configuration Required)

1. Clone this repository
2. Open it in your IDE (VS Code, JetBrains Rider, etc.) with GitHub Copilot installed
3. Open the repository in the devcontainer (your IDE should prompt you)
4. Start using the custom agents immediately with `@terraform-helper` or `@devops-assistant` in Copilot chat

**That's it!** No manual MCP server setup, no configuration files to edit.

### For Repository Maintainers

The magic happens through three integrated components:

#### 1. Devcontainer Configuration (`.devcontainer/`)

The devcontainer automatically:
- Builds a container with Docker-in-Docker support
- Copies the MCP server configuration (`mcp.json`) into the container
- Runs a startup script that launches all configured MCP servers
- Sets the `MCP_CONFIG_PATH` environment variable for discovery

**Key files:**
- `devcontainer.json` - Configures the container and startup behavior
- `mcp.json` - Defines which MCP servers to run and how to start them
- `start-mcp-servers.sh` - Script that automatically starts MCP servers on container startup

#### 2. MCP Server Configuration (`.devcontainer/mcp.json`)

Defines the MCP servers available in this repository:

```json
{
  "servers": {
    "terraform-mcp-server": {
      "type": "local",
      "command": "docker",
      "args": ["run", "--name", "terraform-mcp-server", "-p", "8080:8080", "hashicorp/terraform-mcp-server"],
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

#### 3. Custom Agent Definitions (`.github/copilot-agents.json`)

Defines custom agents that reference the MCP servers:

```json
{
  "agents": {
    "terraform-helper": {
      "name": "Terraform Helper",
      "description": "Expert Terraform assistant with MCP server access",
      "tools": [
        {
          "type": "mcp",
          "server": "terraform-mcp-server"
        }
      ],
      "instructions": "You are an expert Terraform assistant..."
    }
  }
}
```

**Key Insight:** The agent's `tools` array references MCP servers by their key name from `mcp.json`. When a user invokes the agent, GitHub Copilot:
1. Looks up the MCP server definition in the repository's MCP configuration
2. Connects to the running MCP server (started by the devcontainer)
3. Provides the agent with access to the server's tools and context

## Architecture

```
User clones repo
    ↓
Opens in devcontainer
    ↓
Devcontainer starts
    ↓
postStartCommand runs start-mcp-servers.sh
    ↓
MCP servers start automatically (Docker containers, npx processes, etc.)
    ↓
MCP_CONFIG_PATH environment variable points to mcp.json
    ↓
GitHub Copilot reads .github/copilot-agents.json
    ↓
Custom agents registered with references to MCP servers
    ↓
User invokes @terraform-helper in Copilot chat
    ↓
Copilot discovers running terraform-mcp-server via MCP_CONFIG_PATH
    ↓
Agent uses MCP server tools to answer user's question
```

## Adding New MCP Servers

1. **Add the server to `.devcontainer/mcp.json`:**
   ```json
   "my-new-server": {
     "type": "local",
     "command": "docker",
     "args": ["run", "--name", "my-new-server", "-p", "9090:9090", "myorg/my-mcp-server"],
     "address": "http://localhost:9090"
   }
   ```

2. **Reference it in an agent's tools (`.github/copilot-agents.json`):**
   ```json
   "my-custom-agent": {
     "name": "My Custom Agent",
     "tools": [
       {
         "type": "mcp",
         "server": "my-new-server"
       }
     ],
     "instructions": "..."
   }
   ```

3. **Rebuild the devcontainer** - The new server will start automatically.

## Advanced Patterns

### Multiple MCP Servers per Agent

An agent can use multiple MCP servers:

```json
"multi-tool-agent": {
  "name": "Multi-Tool Agent",
  "tools": [
    {
      "type": "mcp",
      "server": "terraform-mcp-server"
    },
    {
      "type": "mcp",
      "server": "azure-mcp-server"
    }
  ],
  "instructions": "Use Terraform MCP for infrastructure code, Azure MCP for cloud resources."
}
```

### Conditional MCP Server Types

Different MCP server types are supported:
- **`local` with `command: "docker"`** - Docker containers (like terraform-mcp-server)
- **`stdio` with `command: "npx"`** - Node.js processes (like ado-mcp-server)
- **`remote`** - HTTP/REST endpoints (like github-mcp-server)

### Environment Variables

Use environment variables for sensitive data (tokens, API keys):

```json
"secure-server": {
  "type": "remote",
  "url": "https://api.example.com/mcp/",
  "requestInit": {
    "headers": {
      "Authorization": "Bearer {{MY_API_TOKEN}}"
    }
  }
}
```

Set the variable in `devcontainer.json`:
```json
"containerEnv": {
  "MY_API_TOKEN": "${localEnv:MY_API_TOKEN}"
}
```

## References

- [GitHub Copilot Custom Agents Documentation](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [Extending Copilot Chat with MCP](https://docs.github.com/en/copilot/customizing-copilot/extending-copilot-chat-with-mcp)
- [Awesome Copilot Examples](https://github.com/github/awesome-copilot)
- [Model Context Protocol (MCP) Specification](https://modelcontextprotocol.io/)

## Troubleshooting

### MCP Server Not Running

Check if the server started:
```sh
docker ps -a
docker logs terraform-mcp-server
```

### Agent Can't Find MCP Server

Verify the environment variable:
```sh
echo $MCP_CONFIG_PATH
cat $MCP_CONFIG_PATH
```

### Custom Agent Not Appearing

Ensure:
- `.github/copilot-agents.json` is valid JSON
- The MCP server name matches exactly between `mcp.json` and `copilot-agents.json`
- You've reloaded the IDE after adding the agent

## Summary

**Yes, it is enough to specify the tools from an MCP server in the agent profile!**

Users who clone your repo and open it in a devcontainer will:
1. Have MCP servers automatically started
2. Have custom agents automatically registered
3. Be able to use the agents immediately with full MCP server access
4. Require zero manual configuration

This pattern provides a seamless experience for repository users while giving you full control over the AI assistance available in your project.

