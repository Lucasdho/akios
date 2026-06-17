#!/usr/bin/env bash
# SessionStart hook: re-states the default skill gates every session.
# It reminds, it does not enforce — the agent can still skip a gate with reason.
cat <<'EOF'
[agentic-kit · Swift/iOS] Always on: superpowers · ponytail · swift-dev.
Default gates (reminder, not enforced — skip only with reason):
- Idea -> spec           -> idea-to-spec (write to specs/, register domain in CLAUDE.md)
- Before ANY code        -> plan mode OR superpowers:brainstorming
- Before hand-writing    -> oss-first (is there a mature tool/lib first?)
- Bug / failure / flake  -> superpowers:systematic-debugging + swift-dev->ios-debugger-agent
- Implementing code      -> ponytail (no over-build/rewrite) + swift-dev writing standards + fewer-permission-prompts
- Creating SwiftUI Views -> native first + swift-dev->swiftui-design-principles (with ponytail)
- Writing tests          -> swift-dev -> swift-testing-pro
- Before "done"          -> subagents: superpowers:verification-before-completion + /code-review
Read AGENTS.md -> Context.md if not already loaded. Durable decisions live in
Claude Code's native auto-memory (MEMORY.md), not a file in the repo.
EOF
