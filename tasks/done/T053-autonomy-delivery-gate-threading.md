---
id: T053
spec: specs/collaboration-autonomy.md
est_tokens: 14k
runner: orchestrator
parallel: false
area: autonomy-delivery-gate
checkpoint: 32
---

# T053 — Thread `autonomy` through `just-vibes` DELIVER + `task-execution`'s Finish gate

> **State:** done

## Description
Wire the flag T052 introduced into actual delivery behavior (`collaboration-autonomy.md` §3, §4,
§5, §6): `just-vibes`'s DELIVER step reads `autonomy` before `collaboration`, `task-execution`'s
hard human gate narrows its just-vibes exception, the run report gains a "Built (undelivered)"
bucket, and team mode's claim-push is explicitly documented as unaffected.

## Files
- `skills/just-vibes/SKILL.md` ("The loop" step 5 DELIVER; "Reporting" section)
- `skills/task-execution/SKILL.md` ("Finish — the hard human gate" section)

## Definition of Done
- `just-vibes/SKILL.md` step 5 (DELIVER) reads `autonomy` first: `manual` → skip push/merge/PR,
  keep commits local, Roadmap status still follows the quality-gate result (green → `done`, red →
  `blocked`, unchanged), append a "Delivery: deferred — autonomy: manual, awaiting human
  push/merge" journal line, and **continue the loop** under `--force` rather than stopping the
  whole run; `auto` → proceed exactly as documented today (`collaboration` picks solo-merge-push
  vs. team-push-PR).
- `just-vibes/SKILL.md`'s "Reporting" section gains a **"Built (undelivered)"** bucket alongside
  Delivered/Parked/Skipped, distinct from Parked (red) and Delivered (already pushed/merged).
- `just-vibes/SKILL.md`'s "Coordination with teammates" section notes the claim-push (step 2) is
  coordination, not delivery, and runs unchanged regardless of `autonomy` (§6, D6) — only the
  step-5 delivery action is gated.
- `task-execution/SKILL.md`'s "Finish — the hard human gate" section narrows its existing
  just-vibes exception to **"just-vibes AND `autonomy: auto`"**; adds the `autonomy: manual` +
  just-vibes path (record finished-and-ready, return control to just-vibes's loop, no literal
  ask-and-wait since no human is present to answer it); states explicitly that outside just-vibes
  the flag has no effect (a human is already present to answer the gate's literal question).
- `grep -n "autonomy" skills/just-vibes/SKILL.md skills/task-execution/SKILL.md` hits in both
  files, in the DELIVER/Reporting/Finish sections specifically (not just a stray mention).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/collaboration-autonomy.md` §3 (D3), §4 (D4), §5 (D5), §6 (D6), §11 CONSEQUENCEs
4–5. Depends on T052 (the flag must exist in `Roadmap.md`/`workflow.yml` before these skills can
read it) — same checkpoint barrier, committed together.
