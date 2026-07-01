# akios — Verification & Learning Loop
**Working spec · v1.0 · kit-evolution family · 2026-06-30**

Closes akios's two post-execution blind spots: **did it really do what the task said** (verification), and
**what did we learn that the next run must not re-learn the hard way** (a hurdles ledger). Adds a
*divergence audit* at the `review → done` seam, formalizes the *three proofs* that answer "did it implement
it right," and defines a *hurdles ledger* that grows from divergences and repeated failures and feeds back
into the priority chain. Answers backlog **B2** (compare planned vs done → save to project context / "common
hurdles" file) and **B19** ("será que implementou certinho msm?"). Realizes **Vision wishlist #3** (the
auto-build/test hook). Complements `task-execution.md` (the seams it plugs into), `just-vibes` (the
autonomous capture path), and `knowledge-architecture.md` (G2 — the hurdles ledger is project knowledge). See
`akios-backlog-map.md` (G5).

> **State:** designed

> **The shift:** akios commits at each checkpoint and archives decisions, but it never *checks the code
> against the intent that produced it*, and it never *remembers a mistake so it stops repeating it.* Today a
> task can drift from its own DoD and ship green; a hurdle solved on Monday is re-hit on Friday. This loop
> makes execution **self-checking** (three proofs before `done`) and **self-correcting** (a ledger the next
> session reads), turning the pipeline from write-once into write-verify-learn.

---

## 1. The divergence audit (D1) — planned vs. done, at `review → done`

`task-execution` moves a task `review → done` "only when the DoD is actually met." This inserts one step
there: **compare what the task *planned* to what was *actually done*, and record material divergence.**

- **Inputs to compare:** the task's `## Description` + `## Definition of Done` + planned `## Files` (intent)
  vs. the actual diff + files touched + decisions taken (reality).
- **A divergence is *material* when** the implementation took a different approach, touched files the task
  didn't name, dropped/added a DoD item, or resolved a decision the task left open. Cosmetic deltas (a
  rename, an obvious helper) are not material.
- **On material divergence:** it is *not* automatically a failure — sometimes the plan was wrong and the code
  is right. The audit **records** it (§3) and decides: (a) code is right, plan was stale → note it, proceed;
  (b) code drifted from a correct plan → loop back to `in-progress` and fix; (c) genuinely open → surface it.

**Decision & reason:** the `review → done` move is the exact moment intent and reality are both in hand, so
it's where the comparison is cheapest and most honest. Treating every divergence as a failure (rejected) is
wrong — under just-in-time development the plan legitimately evolves, and punishing that would fight the kit's
own JIT posture. Treating none as failures (rejected) is the status quo that lets code silently drift from its
DoD. Recording-then-classifying is the only version that both tolerates good drift and catches bad drift.

---

## 2. The three proofs (D2) — the concrete answer to "did it implement it right?"

"Será que implementou certinho" (B19) decomposes into three checkable proofs. A task/spec is *proven* only
when all three that apply are green.

| Proof | What it checks | Mechanism | Applies to |
|---|---|---|---|
| **Build/test proof** | it compiles and the tests pass | the auto-build/test hook (§4) → `xcodebuild` + test battery | every code task |
| **Spec-conformance proof** | it did what the task said + followed the loaded doctrine | the divergence audit (§1) + `/code-review` doctrine (G6) | every task |
| **Visual proof** | it looks like the approved design | `visual-grounding` structured diff vs the prototype | UI tasks only |

- The three map onto the kit's existing gate (`/verify` + `/code-review`) and the UI family's grounding —
  this spec *names* them as a set and makes the **build/test proof automatic** (§4) rather than reliant on a
  manual `/verify`.
- **A red proof parks, never ships** — consistent with `task-execution`'s bounded fix loop and `just-vibes`'
  "park red, never deliver broken."

**Decision & reason:** the anxiety in B19 is real precisely because "it ran" ≠ "it's right" — separating the
three proofs makes the vague worry into three things you can actually see go green, and shows *which* one is
red when something's off. Folding them into one opaque "verify" (rejected) hides which dimension failed;
adding proofs beyond these three (rejected) over-engineers — build, intent, and appearance are the three axes
a feature can be wrong on.

---

## 3. The hurdles ledger (D3) — "common hurdles & how to solve them"

The backlog asks: on divergence, save to the project context so the error isn't repeated — or keep a "common
hurdles and how to solve them" file. This defines that file and how it grows.

- **Where it lives:** `code-references/hurdles.md`, indexed in `code-references/INDEX.md` with domain tags —
  i.e. **it is part of the project's code pack (G2), tier 2 of the priority chain.** A solved recurring
  problem is exactly the kind of curated project knowledge that *should* outrank the baseline when a matching
  task comes up. Recall-worthy, cross-session hurdles also get a one-line pointer in native `MEMORY.md`
  (the recall layer), with the full entry staying in `hurdles.md` (no duplication).
- **Entry format** (one per hurdle, deduplicated):
  ```markdown
  ### <short symptom>            [tags: swiftdata, concurrency]
  - **Hit when:** <the situation that triggers it>
  - **Root cause:** <why it happens>
  - **Fix:** <the resolution that worked>
  - **First seen:** <task/spec> · **Times hit:** <n>
  ```
- **How it grows (observe → confirm → append):** a hurdle is captured when (a) a material divergence taught
  something reusable, or (b) the **same failure is hit a 2nd time** (the same 2nd-occurrence rule that governs
  `preferences.md`). Attended → *propose* the entry at a pause. `just-vibes` → auto-append with rationale +
  journal it. Dedup against existing entries; bump `Times hit` instead of duplicating.
- **How it's read:** because it's an indexed tier-2 reference, `task-execution` loads `hurdles.md` (or the
  matching-tag slice of it) **before** starting a task in that domain — so a known hurdle is avoided *by
  consulting the ledger*, exactly as the priority chain already loads a matching code reference.

**Decision & reason:** putting hurdles in the **code pack at tier 2** (rather than a loose file nobody loads)
is what makes them *actually prevent repetition* — the priority chain already guarantees tier 2 is consulted
before the baseline, so a hurdle placed there is read at the right moment for free. A standalone
`hurdles.md` outside the chain (rejected) would be written and never read — the failure mode of most "lessons
learned" docs. Using the same 2nd-occurrence + observe-confirm discipline as `preferences.md` keeps one-off
noise out (a single stumble is context, not a rule) and reuses a mechanism the kit already trusts.

---

## 4. The auto-build/test hook (D4) — realizes Vision wishlist #3

- **A post-execute hook runs the build + test battery automatically** after a checkpoint/spec, and **parks
  the spec (`Roadmap.md` → `blocked`) if it fails** — without waiting for a manual `/verify`. This is the
  build/test proof (§2) made automatic and the explicit realization of Vision #3 ("Xcode integration hooks —
  a post-execute hook that runs the build and test suite automatically and parks the spec if CI fails").
- **Degrades gracefully:** if the environment denies `xcodebuild` to a hook/subagent (common in background
  sessions — `task-execution` already handles this), it runs inline in the session instead of failing. The
  hook is an *accelerator*, never a hard dependency (consistent with "never let a dead subagent stall
  execution").
- **Plugin-repo note:** in this akios repo there is no `xcodebuild` — the "build/test proof" degrades to the
  DoD audit (grep + YAML validation + install smoke-test), per `Roadmap.md` project-type. The hook is for
  *installed iOS projects*, not for the plugin repo itself.

**Decision & reason:** automating the build/test proof removes the most common way "done" lies — a manual
`/verify` that nobody ran. Parking on red rather than blocking-with-a-prompt fits both attended and
`just-vibes` flows (the latter can't answer a prompt). Making it a hook that *degrades to inline* respects the
kit's standing rule that execution never *depends* on a capability the sandbox can deny.

---

## 5. Where it fires (the seams)

- **`task-execution`** — the divergence audit at `review → done`; loads `hurdles.md` (matching tags) before a
  domain task; the auto-hook after checkpoints; a hurdle *proposal* at a pause (attended).
- **Spec completion / archive** — a **hurdles digest** joins the archive step: recall-worthy hurdles get their
  `MEMORY.md` pointers alongside the durable decisions already recorded there.
- **`just-vibes`** — the three proofs *are* its quality gate (§2); learning happens by auto-appending hurdles +
  journaling; the auto-hook is what makes its unattended "verify" real.
- **`operating-modes` (G4)** — learning posture proposes captures eagerly and explains *why* a hurdle is worth
  remembering; delivery posture proposes at pauses only.

**Decision & reason:** every seam is one akios already has (a lifecycle move, the archive step, the just-vibes
gate) — the loop adds *behavior* at existing points rather than new phases, keeping the pipeline shape intact.

---

## 6. Worked example — the *Squad* slice

- **Divergence:** task `T-squad-list` planned to fetch players in the ViewModel `init`; the implementation
  moved the fetch to `.task {}` to avoid a SwiftData main-actor stall. Material divergence (approach changed).
  The audit classifies it (a): code is right, plan was stale → notes it on the task, proceeds.
- **Hurdle capture:** that same SwiftData main-actor stall is hit a 2nd time in the *Wallet* slice → 2nd
  occurrence triggers a proposal → `code-references/hurdles.md` gains *"SwiftData fetch in VM `init` stalls
  the main actor → fetch in `.task{}` [tags: swiftdata, concurrency]"*, `Times hit: 2`, + a `MEMORY.md`
  pointer. Next time a slice fetches in a VM, `task-execution` loads that hurdle first and avoids it.
- **Three proofs:** build/test proof green (auto-hook ran `xcodebuild test`); spec-conformance green (divergence
  classified benign + `/code-review` clean); visual proof green (`visual-grounding` converged vs the prototype).
  Only then `→ done`.

---

## 7. Empty / edge states

- **First run, empty ledger:** `hurdles.md` absent/empty → tier 2 simply silent for hurdles; behaves as today.
- **Divergence that's genuinely a bug in the plan:** recorded as (a) *plan stale* — and if the spec is the
  source of the staleness, it's flagged for spec revision, not silently patched (respects "specs are the
  memory").
- **Build/test hook unavailable** (sandbox denies `xcodebuild`): degrade to inline build/test; if even that's
  impossible (plugin repo), the build/test proof becomes the DoD audit and says so — never a false green.
- **Same hurdle, new nuance:** don't duplicate — refine the existing entry and bump `Times hit`, matching the
  `preferences.md` dedup discipline.
- **Under `just-vibes`, a divergence needs a human call:** it can't ask — it records the divergence as an open
  risk in the journal + report (deepthink "flag, don't smooth") and proceeds on the reversible option.

---

## 8. Open / next

- **[CONSEQUENCE — to implement]** `task-execution`: the `review → done` divergence audit; load `hurdles.md`
  by tag before a domain task; the hurdle-proposal step; wire the three proofs as the `done` bar.
- **[CONSEQUENCE — to implement]** the post-execute build/test **hook** (Vision #3) + its graceful inline
  degradation; installed by `/akios:init` into `.claude/hooks/`.
- **[CONSEQUENCE — to implement]** `code-references/hurdles.md` + INDEX row convention; the archive step gains
  the hurdles digest → `MEMORY.md` pointers.
- **[CONSEQUENCE — to implement]** `just-vibes` gate uses the named three proofs; learning-mode journal
  "Lessons" (G4) includes captured hurdles.
- **[COMPOSES WITH]** `code-review-doctrine.md` (G6) *is* the spec-conformance proof's review half;
  `knowledge-architecture.md` (G2) owns the ledger's tier-2 placement.
- **[OPEN — tune after use]** the 2nd-occurrence threshold for hurdle capture (same process risk flagged for
  `preferences.md`) — may need domain-specific tuning.
