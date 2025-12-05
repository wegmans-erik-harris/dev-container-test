# Testing Custom Agent with MCP Server Integration

This guide walks you through testing that your custom Copilot agents can properly access and use MCP servers in the devcontainer.

## Prerequisites

- JetBrains Rider (or VS Code) with GitHub Copilot installed
- Docker Desktop running
- This repository cloned locally

## Step-by-Step Testing Procedure

### Phase 1: Verify MCP Server Infrastructure

#### 1.1 Start the Devcontainer

1. Open this repository in your IDE
2. When prompted, reopen in the devcontainer (or use "Reopen in Container")
3. Wait for the container to build and start

#### 1.2 Run the MCP Setup Test Script

In the devcontainer terminal, run:
```bash
/usr/local/bin/test-mcp-setup.sh
```

**Expected Output:**
- ✓ MCP_CONFIG_PATH is set and file exists
- ✓ terraform-mcp-server container is RUNNING
- ✓ Custom agents file exists with terraform-helper defined
- Connection to http://localhost:8080 succeeds (or shows MCP server response)

**If any checks fail:**
- Check the container logs: `docker logs terraform-mcp-server`
- Manually restart the server: `docker restart terraform-mcp-server`
- Re-run the startup script: `sudo /usr/local/bin/start-mcp-servers.sh`

#### 1.3 Verify the MCP Server is Accessible

Try to connect to the Terraform MCP server:
```bash
curl http://localhost:8080
```

**Expected:** Some response from the MCP server (could be an error if it requires specific headers/authentication, but should not be a connection refused error)

### Phase 2: Verify Custom Agent Registration

#### 2.1 Check Agent File Syntax

Validate the JSON syntax:
```bash
cat /workspace/.github/copilot-agents.json | jq '.'
```

**Expected:** The file parses successfully and shows your agent definitions

#### 2.2 Reload IDE/Copilot

- Close and reopen the IDE or reload the window
- This ensures Copilot picks up the custom agent configuration

#### 2.3 Check Available Agents

In your IDE with Copilot:
1. Open Copilot Chat
2. Type `@` to see available agents
3. Look for `@terraform-helper` in the list

**Expected:** You should see `@terraform-helper` as an available agent with the description "An expert Terraform assistant with access to the Terraform MCP server for infrastructure analysis and planning"

### Phase 3: Test Agent Functionality

#### 3.1 Create a Simple Terraform File

Create a test file `test.tf` in your workspace:
```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "ExampleInstance"
  }
}
```

#### 3.2 Test Basic Agent Interaction

In Copilot Chat, try these prompts with the custom agent:

**Test 1: Basic Agent Response**
```
@terraform-helper What is this Terraform configuration doing?
```

**Expected:** The agent should respond about the AWS EC2 instance configuration.

**Test 2: MCP Server Tool Usage (if available)**
```
@terraform-helper Can you validate this Terraform configuration?
```

or

```
@terraform-helper What resources would this create?
```

**Expected:** The agent should use the Terraform MCP server tools to analyze the configuration. You may see indicators that it's using MCP server capabilities.

#### 3.3 Test MCP Server Context Access

**Test 3: Ask for Infrastructure Analysis**
```
@terraform-helper Analyze this Terraform configuration for best practices and security issues.
```

**Expected:** The agent should provide detailed analysis, potentially using Terraform MCP server capabilities to:
- Parse the configuration
- Check for common issues
- Provide recommendations

**Test 4: Request Planning or State Information** (if supported by the MCP server)
```
@terraform-helper What would happen if I apply this configuration?
```

### Phase 4: Verify MCP Server is Actually Being Used

#### 4.1 Monitor MCP Server Logs

While interacting with `@terraform-helper`, watch the MCP server logs in a separate terminal:
```bash
docker logs -f terraform-mcp-server
```

**Expected:** You should see log entries when the agent queries the MCP server (requests, responses, etc.)

#### 4.2 Compare with Regular Copilot

Ask the **same question** to:
1. Regular Copilot (without `@terraform-helper`)
2. The `@terraform-helper` agent

**Expected Difference:**
- Regular Copilot: General knowledge-based response
- `@terraform-helper`: More specific response with potential MCP server tool usage, showing deeper context or validation

### Phase 5: Test Multi-Agent Setup

#### 5.1 Test DevOps Assistant

Try the second agent:
```
@devops-assistant What Azure DevOps features can help with CI/CD?
```

**Expected:** The agent responds with Azure DevOps-specific information

#### 5.2 Verify Agent Isolation

Ensure each agent uses its designated MCP servers:
- `@terraform-helper` should focus on Terraform
- `@devops-assistant` should handle Azure DevOps, Azure, and GitHub topics

## Troubleshooting

### Custom Agent Not Appearing

**Problem:** `@terraform-helper` doesn't show up in the agent list

**Solutions:**
1. Verify the file exists: `ls -la /workspace/.github/copilot-agents.json`
2. Check JSON syntax: `jq '.' /workspace/.github/copilot-agents.json`
3. Reload your IDE completely (close and reopen)
4. Check IDE logs for errors related to custom agents
5. Ensure you have GitHub Copilot installed and authenticated

### MCP Server Not Running

**Problem:** `docker ps` doesn't show terraform-mcp-server

**Solutions:**
1. Check if it exited: `docker ps -a | grep terraform`
2. View exit logs: `docker logs terraform-mcp-server`
3. Manually start it: `docker run --name terraform-mcp-server -p 8080:8080 hashicorp/terraform-mcp-server`
4. Check the startup script logs for errors
5. Verify the Docker image exists: `docker images | grep terraform`

### Agent Works But Doesn't Use MCP Server

**Problem:** Agent responds but doesn't seem to use MCP server capabilities

**Possible Causes:**
1. **MCP server is not running** - Verify with `docker ps`
2. **Connection issues** - Test with `curl http://localhost:8080`
3. **MCP server doesn't support expected tools** - Check the Terraform MCP server documentation for available tools
4. **Discovery mechanism not working** - Verify `echo $MCP_CONFIG_PATH` points to a valid file
5. **Agent configuration mismatch** - Server name in `copilot-agents.json` must exactly match the key in `mcp.json`

### How to Tell if MCP Server is Being Used

**Indicators that the MCP server is active:**
1. More specific/technical responses from the agent
2. Logs in `docker logs terraform-mcp-server` showing requests
3. Agent provides validation or analysis beyond general knowledge
4. Response includes infrastructure-specific details

**Note:** GitHub Copilot may not always explicitly indicate when it's using an MCP server. The integration is designed to be seamless.

## Advanced Testing

### Test with Network Traffic Monitoring

Monitor traffic to the MCP server:
```bash
# In one terminal, watch MCP server logs
docker logs -f terraform-mcp-server

# In another terminal, monitor network connections
netstat -an | grep 8080
```

### Test MCP Server API Directly

If the Terraform MCP server exposes an API, test it directly:
```bash
# Example (adjust based on actual MCP server API)
curl -X POST http://localhost:8080/validate \
  -H "Content-Type: application/json" \
  -d '{"config": "..."}'
```

### Validate Agent Configuration Programmatically

```bash
# Check that agent references valid MCP servers
cat /workspace/.github/copilot-agents.json | jq -r '.agents[].tools[].server' | while read server; do
  if cat /workspace/.devcontainer/mcp.json | jq -e ".servers.\"$server\"" > /dev/null; then
    echo "✓ Server '$server' is defined in mcp.json"
  else
    echo "✗ Server '$server' is NOT defined in mcp.json"
  fi
done
```

## Success Criteria

Your setup is working correctly if:

- ✅ MCP server containers start automatically when devcontainer launches
- ✅ `@terraform-helper` appears in the Copilot agent list
- ✅ Agent responds to Terraform-related questions
- ✅ MCP server logs show activity when agent is used
- ✅ Agent provides more specific/detailed responses than regular Copilot
- ✅ No manual configuration was needed by the user

## Next Steps

Once testing is complete and successful:
1. Document any additional setup requirements in the repository README
2. Add example prompts that work well with the custom agent
3. Share the repository with team members for validation
4. Consider adding more custom agents for other tools/contexts
5. Monitor usage and iterate on agent instructions for better responses

## Reference

- See `README.md` for architecture details
- See `.devcontainer/MCP_README.md` for MCP server documentation
- See `.github/copilot-agents.json` for agent configurations
- Run `/usr/local/bin/test-mcp-setup.sh` for quick health check

