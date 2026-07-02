# akios — Collaboration & Delivery Autonomy
**Working spec · v1.0 · kit-evolution family · 2026-07-02**

Splits **"who else works on this repo"** (`Roadmap.md`'s existing `collaboration: solo | team`)
from **"is `just-vibes` authorized to auto-push/merge at all"** — a fourth orthogonal flag beside
`mode`, `collaboration`, and `posture`. Today `collaboration` silently answers both questions:
`solo` doubles as "it's safe to auto-push," which is a fact about *headcount*, not about
*delivery risk*. A repo can be worked on by a group while the user is the only one running akios
against it (or vice versa) — headcount and push-safety are independent variables. Answers backlog
**B32**. Complements `Roadmap.md` (where the flag lives, same lifecycle as `posture`,
`operating-modes.md`), `just-vibes` (whose DELIVER step this re-gates), and `task-execution`
(whose hard human gate this formalizes rather than replaces).

> **State:** designed

> **Autonomous decision pass:** because no human was present overnight, the remaining open
> decisions in this spec were resolved **autonomously**, `/akios:just-vibes`-style — the
> recommended position was taken for each, alternatives are recorded with why they were rejected,
> and second-order consequences are noted so the user can override anything on read rather than
> re-deriving it. Nothing here is more final than any other `designed` spec; it is simply
> un-reviewed by a human yet.

---

## 1. The flag (D1) — `autonomy: manual | auto` in `Roadmap.md`

`Roadmap.md` gains a fourth flag beside the existing three:

```
## Mode
mode: feature
collaboration: solo
posture: delivery
autonomy: manual          # manual | auto  (default: manual)
```

- **Set at `init`** (a one-line interview question, same batched pass as mode/collaboration/
  posture) and **overridable per session/run**: an argument (`/akios:just-vibes --autonomy=auto`)
  or a spoken switch ("you can push this yourself tonight" / "hold everything for review"). The
  Roadmap value is the default; an override wins for that run only and does not rewrite the flag —
  exactly the lifecycle `operating-modes.md` D1 established for `posture`, reused rather than
  invented a fourth time.
- **Default: `manual`.** This is the conservative pick, not an inference from `collaboration`
  (see D2) — never assume auto-push is safe just because the user is the only one running akios.

**Decision & reason:** reusing the flag-in-Roadmap, set-at-init, session-overridable pattern
`posture` established means threading `autonomy` costs `just-vibes` and `task-execution` one
small conditional each, not a new mechanism. **Rejected: infer `autonomy` from `collaboration`**
(`solo` → `auto`, `team` → `manual`) — this is the exact conflation B32 exists to undo; if
`autonomy` just mirrors `collaboration`, it isn't a second question, it's a renamed first one.
**Rejected: default to `auto`** (today's implicit, undocumented behavior) — a flag whose default
reproduces the risk it exists to gate would ship with the bug still live for every repo that
doesn't immediately discover and flip it.

---

## 2. Independence from `collaboration` (D2) — two questions, four combinations

`collaboration` answers *who else runs akios here*; `autonomy` answers *is unattended delivery
authorized at all*. Both are read at `just-vibes`'s DELIVER step (§3), but they answer different
questions and every combination is valid:

| | `autonomy: manual` | `autonomy: auto` |
|---|---|---|
| **`collaboration: solo`** | build + commit locally on `feature/<spec>`; never push/merge even under `--force` | merge `feature/<spec>` into the default branch + push (today's documented solo behavior) |
| **`collaboration: team`** | build + commit; claim-coordination pushes still happen (§6) but the finished spec's branch is not additionally pushed for delivery, no PR opened | push `feature/<spec>` + open a PR (today's documented team behavior) |

**Decision & reason:** a 2×2 table makes the independence concrete instead of asserting it in
prose — a reader can see that `solo + manual` and `team + auto` are both real, intended states,
not edge cases. **What breaks today without this split:** nothing crashes, but `collaboration:
solo` alone currently *authorizes* `just-vibes --force` to auto-push to the default branch with no
separate check that auto-push is actually wanted — a silent capability grant riding on a flag that
was only ever meant to answer "how many people work here."

---

## 3. What changes in `just-vibes`'s DELIVER step (D3)

`just-vibes`'s loop step 5 (DELIVER) reads `autonomy` **before** `collaboration`:

- **`autonomy: manual`** — skip push/merge/PR entirely. Commits stay local on `feature/<spec>`.
  Roadmap status still moves per the quality gate result (green → `done`, red → `blocked`,
  unchanged from today) — `manual` gates *delivery*, not *build completion*. Append a **"Delivery:
  deferred — autonomy: manual, awaiting human push/merge"** line to
  `.akios/just-vibes-journal.md`, then **continue the loop** to the next fuel unit under
  `--force` (this unit does not stop the whole run; only its own push is withheld).
- **`autonomy: auto`** — proceed exactly as documented today: `collaboration` picks the mechanism
  (solo → merge + push; team → push + PR).

**Decision & reason:** letting the loop continue past a deferred delivery (rather than stopping
the whole run) matches this very build arc's *lived* behavior — every session in Sessions 1–3b
kept building and committing across many units on `alva+ui-strategies` without pushing, then
handed off. Formalizing "keep building, defer only the push" as the `manual` behavior turns that
ad hoc pattern into policy instead of leaving it as something each session re-decided by hand.
**Rejected: stop the entire run on the first deferred delivery.** That would make `manual` behave
like a red gate (which it isn't — the work is green, just not authorized to ship itself), and
would waste the rest of a `--force` run's fuel for no safety gain.

---

## 4. What changes in `task-execution`'s hard human gate (D4)

`task-execution`'s "Finish" section states an exception today: *"running under `/akios:just-vibes`
… the human push/merge gate is waived there: the just-vibes invocation is the authorization."*
This spec narrows that exception:

- The gate is waived **only when `just-vibes` AND `autonomy: auto`.**
- **Outside `just-vibes` entirely** (an interactive `/akios:execute` session): unaffected by this
  flag. A human is already present to answer "push? merge? where?" — `autonomy` has no bearing on
  an interactive ask-and-wait.
- **Under `just-vibes` + `autonomy: manual`:** the gate's literal "ask and wait" cannot apply (no
  human is present to answer, ever — asking would stall the run forever, the exact failure mode
  `just-vibes`'s own unattended rules exist to prevent). Instead of asking, `task-execution`
  records the branch as finished-and-ready and returns control to `just-vibes`'s loop, which
  applies §3's deferral. The *substance* of the gate (nothing is pushed or merged without
  explicit authorization) is preserved; only the mechanism of asking is replaced by a flag that
  was already set in advance.

**Decision & reason:** this is the formalization the handoff calls out directly — every session in
this v0.8.0 arc has behaved as `solo + manual` by hand (building, committing, never pushing)
despite `Roadmap.md` saying only `collaboration: solo` the whole time, which under today's
undocumented default would have authorized `just-vibes --force` to auto-push from session one.
Writing `autonomy: manual` down turns that manual discipline into a flag a future unattended run
respects automatically, instead of relying on every session's author to re-derive and re-apply the
same override from first principles.

---

## 5. Reporting — a distinct "Built (undelivered)" bucket (D5)

`just-vibes`'s end-of-run report gains a bucket alongside the existing Delivered / Parked /
Skipped:

- **Built (undelivered):** units that reached a **green** quality gate under `autonomy: manual` —
  branch name, spec, and the fact that delivery is a human action away. Distinct from **Parked**
  (which means *red*, not ready to ship) and from **Delivered** (which means *already pushed/
  merged*).

**Decision & reason:** without this bucket, a returning human reading the report can't tell "green
but withheld by policy" from "still broken" — conflating them would either make `manual` look like
a bug (why didn't it ship?) or make a human skip checking genuinely-ready work. A fourth, explicit
bucket costs one line per unit and removes the ambiguity.

---

## 6. Team mode's claim-push is unaffected by `autonomy` (D6)

Team mode's claim step (`just-vibes` loop step 2: commit a claim, push immediately, push-rejection
is the lock) is **coordination**, not **delivery**, and runs unchanged under `autonomy: manual`.
`autonomy` only withholds the delivery-specific action at step 5 (merge to the default branch, or
push-for-PR + PR open). A `team + manual` instance still pushes its claim so teammates see
ownership; it just doesn't additionally push the finished feature branch or open a PR for it.

**Decision & reason:** conflating the claim-lock push with the delivery push would either break
team-mode coordination under `manual` (no lock, instances collide) or force `auto` on any team repo
just to keep locking working — both wrong. Scoping `autonomy` strictly to the step-5 delivery
action keeps the two mechanisms (locking vs. shipping) independent, matching this spec's own
governing idea (don't let one flag silently answer two questions).

---

## 7. Worked example — this repo's own history, made explicit

`Roadmap.md` in this repo has read `collaboration: solo` from Session 1 through Session 3c.
Under today's undocumented default (no `autonomy` flag, `solo` alone authorizing auto-push), a
`just-vibes --force` run at any point in that arc would have merged and pushed every spec straight
to `origin/alva+ui-strategies` as it finished. Instead, every session — Sessions 1, 2, 3a, 3b, and
this one — built through `spec-to-tasks`/`task-execution` mechanics applied by hand, committed at
every checkpoint, and explicitly declined to push, leaving 15+ commits local-only ahead of
`origin`. That is `solo + manual` in this spec's terms, chosen by hand every single time because no
formal flag existed to say it once. With this spec built, setting `autonomy: manual` in this repo's
own `Roadmap.md` makes that the *default* behavior of any future `just-vibes` run here, rather than
a discipline each session's author has to remember and reapply.

---

## 8. Empty / edge states

- **No `autonomy` flag (pre-existing repo, not yet migrated):** absent = `manual` (the safe
  default) — a repo onboarded before this spec shipped never silently gains auto-push capability
  it never asked for.
- **`autonomy: auto` but the quality gate is red:** unaffected — `auto` only concerns *whether a
  green unit ships itself*; a red unit is still parked (§3, unchanged from today), regardless of
  `autonomy`.
- **Session override conflicts with the Roadmap default:** the override wins for that run only and
  does not rewrite `Roadmap.md` — identical rule to `posture`'s session-override (D1).
- **Interactive `/akios:execute`, any `autonomy` value:** no effect — the flag only changes
  behavior where no human is present to ask (`just-vibes`); an interactive session already has a
  human to answer the literal question.
- **`autonomy: manual` + `--force` exhausts all fuel:** the run ends with a report whose
  "Built (undelivered)" bucket may be non-empty — that is success, not a stall; nothing was left
  half-built, only un-pushed.

---

## 9. Deliberate exclusions

- **No per-spec `autonomy` override in `Roadmap.md`'s spec table.** The flag is repo-global, same
  granularity as `posture` and `collaboration` — a spec-by-spec autonomy policy is more
  configuration than any request here asked for; revisit only if real use shows specs within one
  repo need genuinely different delivery risk tolerance.
- **No new "ask once per run" prompt under `autonomy: manual` + `just-vibes`.** `just-vibes`'s own
  hard rule ("never ask the user anything") is not carved out for this flag — `manual` means
  *defer*, not *ask-and-block*, precisely so it never reintroduces the stall `just-vibes` exists to
  prevent.
- **No automatic flip from `manual` to `auto` after N clean runs.** A trust-building auto-promotion
  scheme was considered and rejected as unrequested scope — the flag is a deliberate, human-set
  choice; if it should change, a human changes it.

---

## 10. Backlog placement

Registered as **B32** in `akios-backlog-map.md` §1 (already present, 2026-07-01 addition, "Julio's
first `/akios:init` run" batch). Answers **G9** in §3 (already registered):

| # | New spec | Answers | One-line thesis |
|---|---|---|---|
| G9 | `collaboration-autonomy.md` | B32 | Split "who else works on this repo" (`collaboration: solo/team`) from "should just-vibes auto-push/merge" — two independent questions, not one flag standing in for both. |

`Roadmap.md` gets a new row: `collaboration-autonomy.md` | domain "4th Roadmap flag —
`autonomy: manual/auto`, splits delivery-authorization from headcount" | status `designed` |
notes "backlog B32; formalizes the solo+manual discipline every session in this arc has already
kept by hand."

---

## 11. Open / next

- **[CONSEQUENCE — to implement]** `templates/Roadmap.md` + this repo's own `Roadmap.md` gain an
  `## Autonomy` section (`autonomy: {{manual | auto}}`, default `manual`), mirroring the
  `## Posture` section's shape.
- **[CONSEQUENCE — to implement]** `workflow.yml` gains `autonomy: [manual, auto]` beside
  `collaboration`/`posture`.
- **[CONSEQUENCE — to implement]** `commands/init.md` step 1's interview gains the Autonomy
  question; the materialize table's `Roadmap.md` row and step 5's self-check both mention
  `autonomy:`.
- **[CONSEQUENCE — to implement]** `skills/just-vibes/SKILL.md` step 5 DELIVER gains the
  `autonomy`-first gate (§3) and the loop's Reporting section gains the "Built (undelivered)"
  bucket (§5).
- **[CONSEQUENCE — to implement]** `skills/task-execution/SKILL.md`'s "Finish — the hard human
  gate" section narrows its just-vibes exception to `just-vibes AND autonomy: auto` (§4), and
  documents the `autonomy: manual` deferred-recording path.
- **[CONSEQUENCE — to implement]** `templates/AGENTS.md`'s "Working alongside teammates" /
  delivery-behavior sections get a short pointer to this flag alongside `collaboration`.
- **[OPEN — revisit after first use]** whether `autonomy: manual`'s "Built (undelivered)" queue
  should also get a lightweight command (`/akios:deliver` or similar) that ships everything in
  that bucket in one explicit human-invoked pass, rather than requiring per-spec manual
  push/merge. Deferred — no request for it yet, and the existing hard-gate mechanics
  (`task-execution`'s Finish step, run interactively) already cover the single-spec case.
