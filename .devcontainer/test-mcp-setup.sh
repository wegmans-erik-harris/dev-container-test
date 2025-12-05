#!/bin/bash
# Test script to verify MCP server setup

echo "======================================"
echo "MCP Server Configuration Test"
echo "======================================"
echo ""

echo "1. Checking MCP Config File..."
if [ -f "$MCP_CONFIG_PATH" ]; then
  echo "✓ MCP_CONFIG_PATH is set to: $MCP_CONFIG_PATH"
  echo "✓ File exists and contains:"
  cat "$MCP_CONFIG_PATH" | jq '.'
else
  echo "✗ MCP config file not found at: $MCP_CONFIG_PATH"
fi
echo ""

echo "2. Checking Docker Containers..."
echo "All containers:"
docker ps -a
echo ""

echo "3. Checking Terraform MCP Server specifically..."
if docker ps | grep -q terraform-mcp-server; then
  echo "✓ terraform-mcp-server is RUNNING"
  echo "Container details:"
  docker inspect terraform-mcp-server --format='Status: {{.State.Status}}, Running: {{.State.Running}}, ExitCode: {{.State.ExitCode}}'
else
  echo "✗ terraform-mcp-server is NOT running"
  if docker ps -a | grep -q terraform-mcp-server; then
    echo "Container exists but is stopped. Exit code:"
    docker inspect terraform-mcp-server --format='Status: {{.State.Status}}, ExitCode: {{.State.ExitCode}}'
    echo ""
    echo "Container logs:"
    docker logs terraform-mcp-server
  else
    echo "Container does not exist at all"
  fi
fi
echo ""

echo "4. Testing MCP Server Connectivity..."
echo "Attempting to connect to http://localhost:8080..."
curl -v http://localhost:8080 2>&1 | head -20
echo ""

echo "5. Checking Workspace Mount..."
echo "Workspace folder contents:"
ls -la /workspace/
echo ""
echo "Checking for .github folder:"
if [ -d "/workspace/.github" ]; then
  echo "✓ .github folder exists"
  ls -la /workspace/.github/
else
  echo "✗ .github folder NOT found in /workspace"
  echo "Checking alternate locations:"
  find / -name "copilot-agents.json" 2>/dev/null || echo "File not found anywhere"
fi
echo ""

echo "6. Checking Custom Agent Configuration..."
if [ -f "/workspace/.github/copilot-agents.json" ]; then
  echo "✓ Custom agents file exists"
  echo "Agents defined:"
  cat /workspace/.github/copilot-agents.json | jq '.agents | keys'
  echo ""
  echo "terraform-helper agent configuration:"
  cat /workspace/.github/copilot-agents.json | jq '.agents["terraform-helper"]'
else
  echo "✗ Custom agents file not found at /workspace/.github/copilot-agents.json"
fi
echo ""

echo "======================================"
echo "Test Complete"
echo "======================================"

