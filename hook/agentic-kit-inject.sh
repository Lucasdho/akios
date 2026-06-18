#!/usr/bin/env bash
# SessionStart hook: re-states the default skill gates every session.
# It reminds, it does not enforce — the agent can still skip a gate with reason.
cat <<'EOF'
[agentic-kit · Swift/iOS] Always on: superpowers · axiom. Optional (recommended): ponytail — efficiency/anti-over-build.
Default gates (reminder, not enforced — skip only with reason):
- Full feature (idea to code) -> ios-feature-pipeline (idea-to-spec -> speckit -> subagent-driven-development)
- Idea -> spec           -> idea-to-spec (write to specs/, register domain in CLAUDE.md)
- Before ANY code        -> plan mode OR superpowers:brainstorming
- Before hand-writing    -> oss-first (is there a mature tool/lib first?)
- Bug / failure / flake  -> superpowers:systematic-debugging + axiom->axiom-xcode
- Implementing code      -> axiom (domain skill) + fewer-permission-prompts (+ ponytail if installed)
- Creating SwiftUI Views -> native first + axiom->axiom-swiftui (ponytail if installed)
- Writing tests          -> axiom->axiom-testing
- Before "done"          -> subagents: superpowers:verification-before-completion + /code-review
Read AGENTS.md -> Context.md if not already loaded. Durable decisions live in
Claude Code's native auto-memory (MEMORY.md), not a file in the repo.
EOF
