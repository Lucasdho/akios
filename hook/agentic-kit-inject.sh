#!/usr/bin/env bash
# SessionStart hook: reinforces the mandatory skill routing every session.
# Docs alone get ignored; this puts the gates back in context on every start.
cat <<'EOF'
[agentic-kit · Swift/iOS] Always on: superpowers · ponytail · swift-dev. Gates:
- Before ANY code        -> plan mode OR superpowers:brainstorming
- Bug / failure / flake  -> superpowers:systematic-debugging + swift-dev->ios-debugger-agent
- Implementing code      -> ponytail (no over-build/rewrite) + swift-dev writing standards + fewer-permission-prompts
- Creating SwiftUI Views -> native first + swiftui-design-skill (with ponytail + swift-dev)
- Writing tests          -> swift-dev -> swift-testing-pro
- Before "done"          -> subagents: superpowers:verification-before-completion + /code-review
Read AGENTS.md -> Context.md -> Memory.md -> Skills.md if not already loaded.
EOF
