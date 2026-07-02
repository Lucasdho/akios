---
description: A principled, akios-aware pass over the current diff — the built-in /code-review with review-doctrine pre-loaded plus the ALVA/UI conformance checks.
disable-model-invocation: true
---

# /akios:review — Principled code review

Thin wrapper, not a replacement: loads `skills/swift-dev/skills/review-doctrine/GUIDE.md` (the
SOLID/DRY-via-ledger/ACID-scoped-to-persistence checklist + ALVA/UI conformance + folder/SRP
drift table — see `specs/code-review-doctrine.md`), then runs the built-in `/code-review` against
the current diff with that doctrine as context.

**Graduated severity.** Block on correctness + boundary violations (a slice importing another
slice's internals, a multi-responsibility file). Warn on style/DRY/structure (missing
`// custom:` justification, an inline literal instead of a `DesignSystem` token, a DRY candidate
below the ledger's rule-of-three threshold). Never block on a doctrine a project decision (tier 1)
or user pack (tier 2) deliberately overrode — flag the deviation, don't fight the repo's own
architecture.

**DRY reads the ledger, never eyeballs.** Check `Foundation/usage-ledger.json` before suggesting
any extraction; absent a ledger entry crossing the threshold, DRY stays silent — no "you repeated
this, extract it" from a gut call.

**Non-ALVA repo / plugin-docs repo:** the ALVA/UI conformance checks degrade to advisory notes (or
the DoD audit in a repo with no Swift at all) — see the doctrine's own "Empty / edge states".

This is the same doctrine `task-execution`'s finish step and `just-vibes`' GATE step already load
before every claimed-done review — `/akios:review` is for running that exact pass on demand,
mid-session, without waiting for a checkpoint.

Stop when the review is reported. This command never fixes findings itself — apply them as normal
edits, or hand a block-class finding back to `task-execution`'s fix loop.
