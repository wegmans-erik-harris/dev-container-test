# MCP Configuration in the Devcontainer

This devcontainer now relies on the GitHub Copilot CLI to load and manage MCP servers. During `postCreateCommand`, the repository's `.devcontainer/mcp.json` is copied into `/usr/local/share/copilot/mcp.json` and the `COPILOT_ADDITIONAL_MCP_CONFIG` environment variable points at that file. As a result, every `copilot` CLI invocation automatically has access to the declared MCP servers (local, stdio, or remote) without manually starting them through a custom script.

## For AI Assistants and Agents
- Assistants can read `.devcontainer/mcp.json` (in the repo) or `/usr/local/share/copilot/mcp.json` (inside the container) to understand which servers are available and how to connect to them.
- The file supports all MCP server types (`local`, `stdio`, `remote`), so tools can start Docker containers, invoke `npx`, or call remote endpoints as needed when Copilot delegates work.

## For Users
- No manual MCP server setup is required. Use the `copilot` CLI (or the helper script `copilot-with-mcp.sh`) inside the devcontainer and it will automatically load the shared MCP configuration.
- To customize the available servers, edit `.devcontainer/mcp.json` and rebuild the devcontainer so the updated configuration is copied into `/usr/local/share/copilot/mcp.json`.

## Troubleshooting
- To view the active MCP configuration inside the container, run `cat /usr/local/share/copilot/mcp.json`.
- If Copilot CLI cannot reach a Docker-based server, ensure the server image can start successfully by running the command listed in `mcp.json` manually.
- For remote servers that require tokens (e.g., GitHub MCP), verify the relevant environment variables are set before invoking Copilot.

## Extending
- Add new MCP server definitions to `.devcontainer/mcp.json`. The next time the devcontainer is built, the new entries will be available to Copilot CLI automatically.
- Use the same server keys inside `.github/copilot-agents.json` if you want custom Copilot agents to reference those servers.
