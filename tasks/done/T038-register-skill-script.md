---
id: T038
spec: specs/skill-authoring.md
est_tokens: 6k
runner: orchestrator
parallel: false
area: register-skill-script
checkpoint: 24
---

# T038 — `scripts/register-skill.sh` (deterministic registration helper)

> **State:** done

## Description
The small `scripts/` helper `skill-authoring.md` §7 calls for: idempotently edits the
`SKILLS=(...)` array in `scripts/install-skills.sh` and runs the install + smoke-test — so
registering a new skill is a **deterministic edit**, not an LLM string edit prone to the exact
mistake `Context.md`'s "Gotchas" section names as the most common one in this kit.

## Files
- `scripts/register-skill.sh` (new)

## Definition of Done
- `scripts/register-skill.sh <skill-name>` exists, is executable, and:
  - fails loudly if `skills/<skill-name>/` doesn't exist yet (scaffold before registering).
  - is **idempotent**: if `<skill-name>` is already present in `install-skills.sh`'s `SKILLS=()`
    array, it says so and skips the edit rather than duplicating the entry.
  - otherwise appends `<skill-name>` to the array via `awk` (a deterministic text edit, not a
    hand-written diff), then runs `bash scripts/install-skills.sh` to install it into
    `~/.claude/skills/<skill-name>/` and run the existing smoke-test at the bottom of that
    script (which already fails loudly if `SKILL.md` doesn't land).
- Manually verified once against a throwaway name proves idempotency (run twice, second run
  reports "already registered", array has exactly one entry) — reverted before commit, not left
  in `install-skills.sh`.
- `install-skills.sh` itself is untouched by this task (this task only reads/edits it via the
  new script; the array's real, permanent addition of `skill-author` happens in T039).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/skill-authoring.md` §7 ("[CONSEQUENCE — to implement] a small scripts/ helper...
that edits the SKILLS=() array idempotently and runs the smoke-test, so registration is
deterministic rather than an LLM string edit"). Built before T039 (the `skill-author` skill
itself) so that skill can call this script to self-register, same pattern any future
`/akios:new-skill` invocation will use.
