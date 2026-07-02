---
id: T045
spec: specs/verification-and-learning-loop.md
est_tokens: 18k
runner: orchestrator
parallel: false
area: task-execution-verification-mechanism
checkpoint: 28
---

# T045 — `task-execution`: divergence audit, three proofs, hurdles ledger, archive digest

> **State:** done

## Description
Realizes `verification-and-learning-loop.md` §1 (D1, divergence audit), §2 (D2, three proofs),
§3 (D3, hurdles ledger — load/propose/dedup), and the archive-step hurdles digest from §5. All
four land in `skills/task-execution/SKILL.md`, the skill that owns every seam this spec plugs
into.

## Files
- `skills/task-execution/SKILL.md`:
  - lifecycle diagram — new `[Hurdles gate]` line before TDD; `/code-review` line notes it loads
    `review-doctrine`; `move → tasks/done/` now gated on the divergence audit + three proofs
  - new "Hurdles ledger" section (entry format, read/grow/dedup rules, `MEMORY.md` pointer,
    empty-ledger state) — placed as tier-2 priority-chain content, before "The priority chain"
  - new "The divergence audit" section (material-divergence definition, (a)/(b)/(c)
    classification, stale-spec flagging)
  - new "The three proofs" section (build/test · spec-conformance · visual, table + red-parks rule)
  - "Archive on spec completion" — new step 5, the hurdles digest → `MEMORY.md` pointer
  - "Anti-patterns" — two new lines (auto-fail/ignore divergence; shipping on a red proof)

## Definition of Done
- `grep -n "Hurdles gate"` and `grep -n "THREE PROOFS"` both hit the lifecycle diagram.
- "Hurdles ledger" section states: tier-2 placement in `code-references/hurdles.md`, the exact
  entry format (symptom/tags, Hit when, Root cause, Fix, First seen, Times hit), the
  observe→confirm→append growth rule (2nd-occurrence, same as `preferences.md`), the
  attended-propose vs. just-vibes-auto-append split, and the empty-ledger degrade state.
- "The divergence audit" section names all three classifications ((a) plan stale, (b) code
  drifted, (c) genuinely open) and the stale-spec escalation.
- "The three proofs" section's table names exactly three proofs (build/test, spec-conformance,
  visual) with their mechanism and applicability, and states a red proof parks rather than ships.
- "Archive on spec completion" has a 5th step for the hurdles digest, explicitly "no duplication"
  with the full entry staying in `hurdles.md`.
- Two new anti-pattern lines exist covering divergence mishandling and shipping on red.
- `grep -c "hurdles.md" skills/task-execution/SKILL.md` ≥ 3 (gate, ledger section, archive digest).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/verification-and-learning-loop.md` §1–§3, §5. The build/test hook itself (§4,
D4) and its `/akios:init` installation are **T046**, not this task — this task only references
the hook by name in the three-proofs table. The `review-doctrine` reference this task's
`/code-review` line names doesn't exist yet — it's `code-review-doctrine.md`'s own T049, built
next in this session; the forward reference here is intentional (this spec explicitly composes
with G6).
