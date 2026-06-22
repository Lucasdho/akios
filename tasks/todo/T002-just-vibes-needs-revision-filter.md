---
feature: deep-brainstorm-rww-audit
spec: specs/deep-brainstorm-rww-audit.md
task: T002
owner: akios-instance-solo
est_tokens: 8000
runner: inline
---

# T002 — Add `needs-revision` fuel skip to just-vibes

## What

Update `skills/just-vibes/SKILL.md` so that the fuel detection procedure skips specs at
Roadmap status `needs-revision` by default, and only picks them when `--force` is passed.
Also update the PARK logic to prevent delivering a `needs-revision` spec even if it passes
quality gate.

## DoD

1. In the **Fuel detection procedure** (the numbered list under "Fuel — what to work on next"),
   step 3 (reading Roadmap.md for `designed` specs) explicitly states:
   > skip any spec at status `needs-revision` unless `--force` was passed.
2. The fuel precedence section (numbered list) has a note or item explaining `needs-revision`
   and that `--force` overrides the skip.
3. In the GATE / PARK logic (step 4 of "The loop"), a note says a `needs-revision` spec is
   not delivered even after a green quality gate — it must be revised first.
4. `grep -n "needs-revision" skills/just-vibes/SKILL.md` returns at least 3 matches
   (fuel detection, fuel precedence note, PARK note).
5. No other behavior is changed. Only the three targeted additions are made.

## Changes

- File: `skills/just-vibes/SKILL.md`
  - Add `needs-revision` skip rule to fuel detection procedure step 3.
  - Add explanatory note in fuel precedence list after item 4 (designed specs).
  - Add sentence to PARK logic about `needs-revision` + quality gate interaction.

↳ barrier: DoD checks above → commit "feat: skip needs-revision specs in just-vibes fuel detection"
