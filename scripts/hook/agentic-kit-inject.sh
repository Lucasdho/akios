#!/usr/bin/env bash
# SessionStart hook: re-states the default skill gates every session.
# It reminds, it does not enforce — the agent can still skip a gate with reason.
# This is a compressed summary of the gate table in templates/AGENTS.md — intentional.
# Don't try to keep it word-for-word in sync with AGENTS.md; keep it short for fast injection.
cat <<'EOF'
[agentic-kit · Swift/iOS] Always on: superpowers · axiom. Optional (recommended): ponytail — efficiency/anti-over-build.
Default gates (reminder, not enforced — skip only with reason):
- Full feature (idea to code) -> ios-feature-pipeline (idea-to-spec -> spec-to-tasks -> task-execution)
- Idea -> spec           -> idea-to-spec (write to specs/, register domain in CLAUDE.md)
- Before ANY code        -> plan mode OR superpowers:brainstorming
- Before hand-writing    -> oss-first (is there a mature tool/lib first?)
- Bug / failure / flake  -> superpowers:systematic-debugging + axiom-build
- Implementing code      -> axiom (domain skill) + fewer-permission-prompts (+ ponytail if installed)
- Creating SwiftUI Views -> native first + axiom-swiftui (ponytail if installed)
- Writing tests          -> axiom-testing
- Before "done"          -> subagents: superpowers:verification-before-completion + /code-review
Read AGENTS.md -> Context.md if not already loaded. Durable decisions live in
Claude Code's native auto-memory (MEMORY.md), not a file in the repo.
EOF
