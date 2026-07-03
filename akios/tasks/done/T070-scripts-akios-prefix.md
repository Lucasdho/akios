---
id: T070
spec: specs/akios-footprint-consolidation.md
est_tokens: 8k
runner: orchestrator
parallel: false
area: scripts
checkpoint: 39
---

# T070 — `scripts/*.sh` (+ `scripts/hook/*.sh`): `akios/` path rewrite

> **State:** todo

## Description
Sweep the scripts that reference the old root-level housekeeping paths (install/registration
scripts and hooks that touch `Context.md`/`Roadmap.md`/`specs/`/`tasks/`). `alva-usage-ledger.sh`
already writes to `.claude/scripts/` post-T056 — this task only touches its references to the
housekeeping paths this spec relocates, not that unrelated destination.

## Files
- `scripts/alva-usage-ledger.sh`
- `scripts/install.sh`
- `scripts/register-skill.sh`
- `scripts/test-kit.sh`
- `scripts/hook/post-checkpoint-verify.sh`
- `scripts/hook/agentic-kit-inject.sh`

## Definition of Done
- Every `specs/`, `tasks/`, `Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml` path literal
  in the 6 files above gains the `akios/` prefix.
- Any shell logic that checks for file *existence* at these paths (not just string references —
  e.g. an `if [ -f Context.md ]` style check) is updated to check the new `akios/`-prefixed path,
  not just its printed/logged text.
- `bash -n` on each edited script still passes (no syntax breakage from the edit).
- `grep -n "specs/\|tasks/\|Context\.md\|Roadmap\.md\|Vision\.md\|workflow\.yml" scripts/alva-usage-ledger.sh scripts/install.sh scripts/register-skill.sh scripts/test-kit.sh scripts/hook/post-checkpoint-verify.sh scripts/hook/agentic-kit-inject.sh`
  shows only `akios/`-prefixed forms.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §13. `scripts/akios-instance.sh` and
`scripts/check-update.sh` were grepped and confirmed to have **no** old-path references — don't
touch them (they'd be a no-op edit). `parallel: false` because shell scripts touching adjacent
hook wiring are lower-risk to review serially in one pass than to split.
