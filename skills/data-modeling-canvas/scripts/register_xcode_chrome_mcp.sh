#!/bin/bash
# Registers the "chrome" (chrome-devtools-mcp) MCP server for a single Xcode
# project inside the embedded Claude agent's config, so that agent can drive
# the "Data Modeling Founder Lens" canvas (or any other page) from within
# Xcode 26.3+.
#
# Why this exists: Xcode's embedded agent runs each MCP server's stdio
# process in a sandbox that does NOT inherit the user's shell PATH/.zshrc.
# `command`, `env`, and args must therefore all be absolute paths — a bare
# "npx" in `command` will fail to launch.
#
# Usage:
#   ./register_xcode_chrome_mcp.sh /absolute/path/to/YourProject
#
# What it does:
#   1. Resolves an absolute path to `npx` via `command -v npx`.
#   2. Locates (or creates) ~/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/.claude.json
#   3. Backs up the existing file (timestamped .bak) before touching it.
#   4. Merges (never overwrites) a `projects."<path>".mcpServers.chrome` entry
#      via a Python JSON merge, preserving every other key/project untouched.
#   5. Sets `hasTrustDialogAccepted: true` for that project entry.
#   6. Validates the resulting JSON with `python3 -m json.tool`.
#   7. Prints a diff against the backup so the caller can review exactly
#      what changed.
#
# Safety: this script is additive-only. It never deletes or rewrites another
# project's entry or another mcpServers key under the target project.

set -euo pipefail

PROJECT_KEY="${1:-}"

if [ -z "$PROJECT_KEY" ]; then
  echo "Usage: $0 /absolute/path/to/YourXcodeProjectFolder" >&2
  exit 1
fi

if [[ "$PROJECT_KEY" != /* ]]; then
  echo "Error: project path must be absolute (got: $PROJECT_KEY)" >&2
  exit 1
fi

NPX_PATH="$(command -v npx || true)"
if [ -z "$NPX_PATH" ]; then
  echo "Error: npx not found on PATH. Install Node.js first." >&2
  exit 1
fi
NPX_DIR="$(dirname "$NPX_PATH")"

CONFIG_DIR="$HOME/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig"
CONFIG_FILE="$CONFIG_DIR/.claude.json"

mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_FILE" ]; then
  echo '{"projects":{}}' > "$CONFIG_FILE"
  echo "Created new config file at $CONFIG_FILE"
fi

BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Backup: $BACKUP_FILE"

python3 - "$CONFIG_FILE" "$NPX_PATH" "$NPX_DIR" "$PROJECT_KEY" <<'PYEOF'
import json, sys, collections

config_file, npx_path, npx_dir, project_key = sys.argv[1:5]

with open(config_file, "r") as f:
    data = json.load(f, object_pairs_hook=collections.OrderedDict)

data.setdefault("projects", collections.OrderedDict())
projects = data["projects"]
projects.setdefault(project_key, collections.OrderedDict())
proj = projects[project_key]
proj.setdefault("mcpServers", collections.OrderedDict())

proj["mcpServers"]["chrome"] = collections.OrderedDict([
    ("type", "stdio"),
    ("command", npx_path),
    ("args", ["-y", "chrome-devtools-mcp@latest"]),
    ("env", collections.OrderedDict([("PATH", f"{npx_dir}:/usr/bin:/bin")])),
])
proj["hasTrustDialogAccepted"] = True

with open(config_file, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

print("Merged mcpServers.chrome into projects[%r]" % project_key)
PYEOF

python3 -m json.tool "$CONFIG_FILE" > /dev/null
echo "JSON valid."

echo "--- diff vs backup ---"
diff -u "$BACKUP_FILE" "$CONFIG_FILE" || true

cat <<EOF

Next steps:
  1. Restart Xcode.
  2. Open the Agent panel in project: $PROJECT_KEY
  3. Type /context and confirm "chrome" tools are listed.
EOF
