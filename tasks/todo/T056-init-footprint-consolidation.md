---
id: T056
spec: specs/init-reliability-and-ux.md
est_tokens: 10k
runner: orchestrator
parallel: false
area: init-footprint
checkpoint: 34
---

# T056 — Footprint consolidation: `alva-usage-ledger.sh` moves under `.claude/scripts/`

> **State:** todo

## Description
The one real footprint move from `init-reliability-and-ux.md` §5 (D5): relocate the
materialized copy of `alva-usage-ledger.sh` from a bare root-level `scripts/` folder to
`.claude/scripts/alva-usage-ledger.sh` — namespaced under the directory already used for
committed akios config, instead of a folder name a consumer repo is likely to already own for its
own scripts. Update every reference to the old path. Document the `.akios/` unconditional-
gitignore decision (§6, D6) and the deliberate non-consolidation of root-convention files/content
folders (§5) inline in `commands/init.md` for a future reader.

## Files
- `commands/init.md` (§3 materialize table's `alva-usage-ledger.sh` row; the pre-commit-hook
  append instruction; §0 migrate-path branch; §5 self-check)
- `skills/task-execution/SKILL.md` (reference to `scripts/alva-usage-ledger.sh`)
- `skills/swift-dev/skills/review-doctrine/GUIDE.md` (reference to `scripts/alva-usage-ledger.sh`)

## Definition of Done
- `commands/init.md`'s materialize table's `alva-usage-ledger.sh` destination is
  `.claude/scripts/alva-usage-ledger.sh` (source column unchanged —
  `${CLAUDE_PLUGIN_ROOT}/scripts/alva-usage-ledger.sh` is the plugin's own template source, not
  the consumer-repo destination).
- The pre-commit-hook-append instruction references the new destination path.
- `commands/init.md` §0's "Recorded < installed" migrate-path branch documents: copy to the new
  path, verify it landed (per T055's verification discipline), re-point the pre-commit hook line,
  **then** remove the old root-level file — never delete-then-copy — scoped to that one named
  file only.
- §5 (Self-check) checks for `.claude/scripts/alva-usage-ledger.sh` (not the old path).
- `skills/task-execution/SKILL.md` and `skills/swift-dev/skills/review-doctrine/GUIDE.md` both
  reference `.claude/scripts/alva-usage-ledger.sh`.
- `commands/init.md` gains a short note (near §3's folder-tree/footprint prose) recording *why*
  root-convention files, content folders, and the ALVA scaffold are deliberately excluded from
  consolidation, and that `.akios/` stays unconditionally gitignored (no yes/no prompt) — so a
  future reader sees this was a decision, not an oversight.
- `grep -rn "scripts/alva-usage-ledger.sh" commands/init.md skills/task-execution/SKILL.md
  skills/swift-dev/skills/review-doctrine/GUIDE.md` shows only the `.claude/scripts/` form (no
  bare `scripts/alva-usage-ledger.sh` survivors outside the plugin's own template source at
  this repo's own `scripts/alva-usage-ledger.sh`, which is intentionally unmoved — it's the
  template, not the materialized copy).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/init-reliability-and-ux.md` §5 (D5), §6 (D6), §8 (migrate-path edge state). This
repo's own `scripts/alva-usage-ledger.sh` (the plugin's template source at
`${CLAUDE_PLUGIN_ROOT}/scripts/alva-usage-ledger.sh`) is **not** moved by this task — only the
destination path `/akios:init` copies it *to* in a consumer repo changes.
