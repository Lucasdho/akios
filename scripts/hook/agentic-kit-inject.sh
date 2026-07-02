#!/usr/bin/env bash
# SessionStart hook: re-states the default skill gates every session.
# It reminds, it does not enforce — the agent can still skip a gate with reason.
# This is a compressed summary of the gate table in templates/AGENTS.md — intentional.
# Don't try to keep it word-for-word in sync with AGENTS.md; keep it short for fast injection.

# Pack discovery (knowledge-architecture.md §1/§2) — cheap, manifest-only scan. Never loads a
# pack's references here; this only tells the session what's available to route to later.
_akios_discover_packs() {
  local names=()
  for manifest in knowledge/*/pack.yml "$HOME/.claude/akios/knowledge"/*/pack.yml; do
    [ -f "$manifest" ] || continue
    local n
    n=$(grep -m1 '^name:' "$manifest" | sed 's/^name: *//')
    [ -n "$n" ] && names+=("$n")
  done
  if [ "${#names[@]}" -gt 0 ]; then
    printf 'Knowledge packs discovered: %s (manifest-only — loaded on demand by pack:<domain> task tags).\n' "${names[*]}"
  fi
}
_akios_discover_packs

cat <<'EOF'
[agentic-kit · Swift/iOS] Always on (internal, no external deps): swift-dev (domain) · task-execution (execute). Optional: ponytail.
Scope: tuned for Apple/Swift. Non-Apple code (web/Android/non-Swift backend) -> warn it's outside specialization, then help if asked.
Priority chain (first tier with an answer wins): project (MEMORY.md+code) -> knowledge packs, curated (code-references/ = code pack) -> ~/.claude/akios/preferences.md -> baseline packs (swift-dev = ios pack).
Proportionality: gates are a map to knowledge you lack, not a toll on every file. Mechanical
pattern-copy from an existing repo file (mirror a screen/VM, rename, obvious one-liner) -> just
do it; the precedent is the routing. Load a guide only when it would change what you ship.
Sizing & subagent economy: quick task (1 file, mechanical, low-risk) -> do it inline; real spec
(multi-file, new behavior) -> the pipeline. Work inline by default: dispatch a subagent ONLY when the
session is >=120k tokens (~60% of 200k) AND the task is heavy/isolatable. When you do: cheapest model
that fits (simple -> haiku, spec end-to-end -> sonnet; never more capable than the task needs) and send
only the task's slice -> never clone your whole context (a subagent is billed per token you hand it).
Orchestration runs on opus OR sonnet -> sonnet is the budget default; pick per budget.
Single source: spec state lives only in Roadmap.md -> never mirror the ## Specs table into CLAUDE.md.
Modes: brainstorm/plan -> plan mode (review before edits); execute -> accept-edits/auto (Shift+Tab cycles).
Autonomous: /akios:just-vibes drives the whole pipeline unattended (default: one unit then stop; --force:
loop). It waives the human push/merge gate (invocation = authorization) but KEEPS the quality gate
(verify+review+fix loop; park red, never deliver broken).
Team mode (Roadmap collaboration: team): claim a unit before working it (committed owner: in task/Roadmap),
respect teammate Akios-Instance signatures, edit only your Roadmap line (status monotonic, higher wins).
Default gates (reminder, not enforced — consult when you need the knowledge):
- Full feature (idea to code) -> ios-feature-pipeline (reads workflow.yml: brainstorm -> plan -> design -> execute)
- Idea -> spec           -> idea-to-spec (/akios:brainstorm; write to specs/, register in Roadmap.md)
- Spec -> tasks          -> spec-to-tasks (/akios:plan; writes tasks/todo/)
- Before hand-writing    -> oss-first (is there a mature tool/lib first?)
- Implementing Swift     -> swift-dev (domain router) + fewer-permission-prompts
- SwiftUI Views          -> swift-dev -> swiftui-pro
- Writing tests          -> swift-dev -> swift-testing-pro
- Bug / failure / flake  -> swift-dev -> ios-debugger-agent
- Executing the backlog  -> task-execution (/akios:execute)
- Before "done"          -> /verify + /code-review
Read AGENTS.md -> Context.md if not already loaded. Durable project decisions live in
Claude Code's native auto-memory (MEMORY.md); transferable user taste in ~/.claude/akios/preferences.md.
EOF
