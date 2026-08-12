# Enabling this skill's browser driving from Xcode's embedded agent

## Why this exists

This skill normally drives the data-modeling-canvas app (running at
`~/.akios/artifacts/data-modeling-canvas/`, see the main `SKILL.md` golden
path) using the `claude-in-chrome` MCP tools available in Claude Code /
claude.ai. Xcode 26.3+'s **embedded Claude agent** (the "Agent" panel inside
Xcode) does not have `claude-in-chrome` — it needs its own MCP server
registered so it can control a Chrome tab:
[`chrome-devtools-mcp`](https://www.npmjs.com/package/chrome-devtools-mcp),
run over stdio via `npx`.

Once registered for a given Xcode project, the embedded agent gets a
`chrome` MCP server whose tools can navigate/read/click a page — including
the running data-modeling-canvas dev server — so the same golden path in
`SKILL.md` (find/start the app, drive it via `window.agentTools`) can be
followed from inside an Xcode project's Agent panel too, just with a
different tool namespace than `claude-in-chrome`.

## Key facts about the config

- Config file: `~/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/.claude.json`
- Structure: top-level `projects` object, keyed by the **absolute path** of
  the Xcode project folder (the directory containing the `.xcodeproj` /
  `.xcworkspace`, not the file itself). Each project entry has its own
  `mcpServers` map and a `hasTrustDialogAccepted` flag.
- **Everything must be an absolute path.** Xcode launches each MCP server's
  stdio process in a sandbox that does **not** inherit the user's shell PATH
  or `.zshrc`/`.bashrc`. A bare `"npx"` in `command` will fail silently to
  launch — `command` must be the absolute path from `command -v npx`
  (typically `/opt/homebrew/bin/npx` on Apple Silicon with Homebrew, or
  `/usr/local/bin/npx` on Intel), and `env.PATH` must include that binary's
  directory plus `/usr/bin:/bin` for the tool's own subprocess needs.
- The file may not exist yet (first run) or may exist without a `projects`
  key yet (Xcode creates it on first agent use for other settings). Both
  cases must be handled by creating rather than assuming presence.

## The registration entry

```json
{
  "projects": {
    "<absolute-path-to-project-folder>": {
      "mcpServers": {
        "chrome": {
          "type": "stdio",
          "command": "<absolute-path-to-npx>",
          "args": ["-y", "chrome-devtools-mcp@latest"],
          "env": { "PATH": "<npx-dir>:/usr/bin:/bin" }
        }
      },
      "hasTrustDialogAccepted": true
    }
  }
}
```

## How it was done manually (reference)

1. `command -v npx` → absolute path to npx.
2. Identify the target project's folder (the directory holding the
   `.xcodeproj`/`.xcworkspace`) — **ask the user to confirm** if there is any
   ambiguity (e.g. running from a directory with multiple candidate
   projects underneath, like a home directory). Never guess when more than
   one project is found.
3. Read the config file in full if it exists (never blind-overwrite);
   create `{"projects": {}}` if it doesn't.
4. **Back up the existing file** (timestamped copy) before writing.
5. Merge the `chrome` entry into `projects[<path>].mcpServers`, using a
   real JSON parse + re-serialize (e.g. Python's `json` module) rather than
   text-editing — this guarantees every other key, other projects, and
   other `mcpServers` entries under the same project are preserved exactly.
6. Set `hasTrustDialogAccepted: true` on that project entry.
7. Validate with `python3 -m json.tool` on the final file.
8. Diff the result against the backup and show it to the user.
9. Remind the user to restart Xcode and run `/context` in the Agent panel
   to confirm the `chrome` tools appear.

## Automated version

`scripts/register_xcode_chrome_mcp.sh` implements steps 1 and 3–8 as a
single idempotent, additive-only script:

```bash
scripts/register_xcode_chrome_mcp.sh /absolute/path/to/YourXcodeProjectFolder
```

It still requires a human (or the calling skill logic) to resolve/confirm
*which* project folder is the target (step 2) — that's a judgment call, not
a script's job, since guessing wrong would trust-dialog-accept and wire
browser tools into the wrong project.

After running it, restart Xcode and check `/context` in the Agent panel for
that project to confirm the `chrome` server's tools are listed.
