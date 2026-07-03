---
id: T069
spec: specs/akios-footprint-consolidation.md
est_tokens: 13k
runner: orchestrator
parallel: true
area: skills/ios-kit
checkpoint: 38
---

# T069 — `swift-dev` + review-doctrine guide + `ios-feature-pipeline` + `ios-agentic-kit` + sandbox ref: `akios/` path rewrite

> **State:** todo

## Description
The Swift/iOS-kit cluster: `swift-dev` (domain router) and its bundled `review-doctrine/GUIDE.md`
(already touched once by T056 for the `alva-usage-ledger.sh` path — this task is the broader
`specs/`/`tasks/`/`Roadmap.md` sweep on top of that), `ios-feature-pipeline` (workflow.yml-reading
entry point), `ios-agentic-kit` (meta-system setup guide), and its `references/sandbox.md`.

## Files
- `skills/swift-dev/SKILL.md`
- `skills/swift-dev/skills/review-doctrine/GUIDE.md`
- `skills/ios-feature-pipeline/SKILL.md`
- `skills/ios-agentic-kit/SKILL.md`
- `skills/ios-agentic-kit/references/sandbox.md`

## Definition of Done
- Every `specs/`, `tasks/`, `Roadmap.md`, `Context.md`, `Vision.md`, `workflow.yml` path literal
  in all 5 files gains the `akios/` prefix.
- `review-doctrine/GUIDE.md`'s existing `.claude/scripts/alva-usage-ledger.sh` reference (from
  T056) is unchanged — not this spec's scope.
- `grep -n "specs/\|tasks/\|Roadmap\.md\|Context\.md\|Vision\.md\|workflow\.yml" skills/swift-dev/SKILL.md skills/swift-dev/skills/review-doctrine/GUIDE.md skills/ios-feature-pipeline/SKILL.md skills/ios-agentic-kit/SKILL.md skills/ios-agentic-kit/references/sandbox.md`
  shows only `akios/`-prefixed forms (excluding the unrelated `.claude/scripts/` line).

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §13. `ios-agentic-kit`'s doc explains what
the kit installs into a consumer repo — double-check its description of the resulting folder
tree matches spec §9's after-state, not just isolated path literals.
