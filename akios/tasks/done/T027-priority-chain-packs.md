---
id: T027
spec: specs/knowledge-architecture.md
est_tokens: 8k
runner: orchestrator
parallel: false
area: priority-chain-packs
checkpoint: 16
---

# T027 — Priority chain widens: knowledge packs generalize tiers 2 and 4

> **State:** done

## Description
Widen the locked 4-tier priority chain's tiers 2 and 4 from "code-references" / "swift-dev" to
their general form — "knowledge packs, user-curated" (tier 2) and "baseline packs, shipped
floor" (tier 4) — without adding or reordering any tier. `code-references/` becomes the
project's auto-built **code pack** (same mechanism, reframed); `swift-dev` becomes the shipped
`ios` baseline pack. Implements `knowledge-architecture.md` §3 (D4).

**Reconciliation note:** the source spec says "`preferences-and-priority.md` §2 annotated," but
that spec file no longer exists in `specs/` (archived/removed before this session — its content
already lives in `templates/AGENTS.md`'s priority-chain section and `scripts/hook/
agentic-kit-inject.sh`'s summary). Annotate those two live locations instead.

## Files
- `templates/AGENTS.md` (priority chain section)
- `scripts/hook/agentic-kit-inject.sh` (one-line priority-chain summary)
- `skills/ios-agentic-kit/SKILL.md` (priority chain section — portable version)

## Definition of Done
- `templates/AGENTS.md`'s priority chain shows tier 2 as "Sample code / Code References
  (`code-references/` — the project's auto-built code pack; other user-curated knowledge packs
  route here too)" and tier 4 as "`swift-dev` (the shipped `ios` knowledge pack; other baseline
  packs land here)" — no tier added, no tier reordered.
- Same widening reflected in `skills/ios-agentic-kit/SKILL.md`'s priority chain.
- `scripts/hook/agentic-kit-inject.sh`'s one-line chain summary updated to match (kept short).
- `grep -n "knowledge pack" templates/AGENTS.md` finds at least one hit.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/knowledge-architecture.md` §3 (D4). The chain's *strict cascade* behavior is
unchanged — this task only widens tier labels, it doesn't touch tier order or blending rules.
