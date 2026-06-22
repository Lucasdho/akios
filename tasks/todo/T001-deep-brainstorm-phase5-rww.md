---
feature: deep-brainstorm-rww-audit
spec: specs/deep-brainstorm-rww-audit.md
task: T001
owner: akios-instance-solo
est_tokens: 12000
runner: inline
---

# T001 — Add Phase 5 (R-W-W Audit) to deep-brainstorm skill

## What

Insert a new **Phase 5 — Validate (R-W-W audit)** section into
`skills/deep-brainstorm/SKILL.md` between the current Phase 4 (Spec-burst) and Phase 5
(Review & close), and renumber the old Phase 5 to Phase 6.

## DoD

1. `skills/deep-brainstorm/SKILL.md` has a `## Phase 5 — Validate (R-W-W audit)` section
   placed immediately after the `## Phase 4 — Spec-burst` section.
2. The old `## Phase 5 — Review & close` is now `## Phase 6 — Review & close`.
3. Any internal reference to "Phase 5" inside the old Review section now says "Phase 6".
4. Phase 5 content matches the spec (§5): scoring rubric, rww-audit.md write, Roadmap.md
   update for Red/Yellow/Green, interactive vs unattended mode behavior.
5. `grep -n "Phase 5" skills/deep-brainstorm/SKILL.md` returns only the new Validate heading
   and any legitimate references to it. No stale "Phase 5 — Review" text remains.
6. File is valid Markdown (no broken frontmatter, no raw `---` mid-section collision).

## Changes

- File: `skills/deep-brainstorm/SKILL.md`
  - Insert Phase 5 section after Phase 4 closing paragraph.
  - Rename Phase 5 → Phase 6 heading.
  - Update "Phase 6" summary copy at the end of the file to reflect the new phase number.

↳ barrier: DoD checks above → commit "feat: add Phase 5 R-W-W audit to deep-brainstorm"
