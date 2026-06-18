> Adapted from [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide) (MIT).

# XcodeBuildMCP Reference

## All Available Tools

| Tool | Description |
|------|-------------|
| `mcp__xcodebuildmcp__discover_projects` | Find Xcode projects/workspaces |
| `mcp__xcodebuildmcp__list_schemes` | List available build schemes |
| `mcp__xcodebuildmcp__build_sim_name_proj` | Build for iOS simulator |
| `mcp__xcodebuildmcp__build_device_proj` | Build for physical device |
| `mcp__xcodebuildmcp__test_sim_name_proj` | Run tests on simulator |
| `mcp__xcodebuildmcp__clean` | Clean build products |
| `mcp__xcodebuildmcp__list_simulators` | List available simulators |
| `mcp__xcodebuildmcp__boot_simulator` | Boot a simulator |
| `mcp__xcodebuildmcp__install_app` | Install app on simulator/device |
| `mcp__xcodebuildmcp__launch_app` | Launch installed app |
| `mcp__xcodebuildmcp__capture_logs` | Capture runtime logs |
| `mcp__xcodebuildmcp__screenshot` | Capture simulator screenshot |
| `mcp__xcodebuildmcp__swift_package_build` | Build Swift package |
| `mcp__xcodebuildmcp__swift_package_test` | Run Swift package tests |
| `mcp__xcodebuildmcp__create_project` | Scaffold new iOS/macOS project |

## Environment Variable Expansion in .mcp.json

```json
{
  "mcpServers": {
    "custom-server": {
      "command": "${HOME}/tools/server",
      "env": {
        "API_KEY": "${MY_API_KEY}",
        "BASE_URL": "${API_URL:-https://default.example.com}"
      }
    }
  }
}
```

- `${VAR}` — expand variable
- `${VAR:-default}` — use default if unset

## MCP Scopes

| Scope | Description | Storage |
|-------|-------------|---------|
| `local` (default) | You, current project | `~/.claude.json` under project path |
| `project` | Team via git | `.mcp.json` |
| `user` | You, all projects | `~/.claude.json` |

## Management Commands

```bash
claude mcp list
claude mcp get XcodeBuildMCP
claude mcp remove XcodeBuildMCP

# In session:
/mcp   # status + OAuth auth
```

## Output Limits

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
MCP_TIMEOUT=10000 claude
```

## CLAUDE.md Build Commands Block

```markdown
## Build Commands
- **Build**: `mcp__xcodebuildmcp__build_sim_name_proj`
- **Test**: `mcp__xcodebuildmcp__test_sim_name_proj`
- **Clean**: `mcp__xcodebuildmcp__clean` before major rebuilds
- **Logs**: `mcp__xcodebuildmcp__capture_logs` for runtime issues
```
