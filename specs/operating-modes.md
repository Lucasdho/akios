# akios — Operating Modes (Learning vs. Delivery)
**Working spec · v1.0 · kit-evolution family · 2026-06-30**

Adds a **posture** to akios — a third orthogonal flag (beside `mode` and `collaboration` in `Roadmap.md`)
that selects whether the kit **teaches the *why*** as it builds (**learning**) or **just ships** with
decisions recorded but not explained (**delivery**, the default). Answers backlog **B3**. Complements
`pipeline.md`/`Roadmap.md` (where the flag lives), `knowledge-architecture.md` (G2 — learning mode teaches
*from* the packs), and `verification-and-learning-loop.md` (G5 — learning mode is where captures are
proposed eagerly). See `akios-backlog-map.md` (G4).

> **State:** designed

> **The shift:** the backlog notes these practices "carry good habits the LLM/user doesn't know." akios
> already *records* its decisions (specs, task files, MEMORY) but it doesn't *teach* them — a developer can
> ship a whole feature without ever learning *why* a component is dumb or *why* DRY is deferred to a ledger.
> Learning posture makes akios narrate the principle behind each significant choice, turning every build into
> a lesson in the doctrines the developer values; delivery posture keeps today's ship-first quiet.

---

## 1. The flag (D1) — `posture: learning | delivery` in `Roadmap.md`

`Roadmap.md` gains a third flag beside the existing two:

```
## Mode
mode: feature
collaboration: solo
posture: delivery        # learning | delivery  (default: delivery)
```

- **Set at `init`** (a one-line interview question) and **overridable per session**: an argument
  (`/akios:execute --learning`) or a spoken switch ("teach me as you go" / "just ship it"). The Roadmap value
  is the default; a session override wins for that session without rewriting the flag.
- **Orthogonal to the other flags:** any `mode`×`collaboration`×`posture` combination is valid. Posture
  changes *how akios communicates and captures*, never *what it builds* — a learning-mode feature and a
  delivery-mode feature produce identical code.

**Decision & reason:** posture is exactly parallel to `collaboration` (a cross-cutting flag every phase reads
and adjusts to), so it belongs in the same place with the same lifecycle — no new mechanism needed. Making it
a separate mode value (rejected) would force false exclusivity (you couldn't have team + learning). Making it
a `preferences.md` entry (rejected) is wrong scope: posture is a *per-project/per-session* stance, and
preferences are *transferable taste* — a user may learn on a side project and ship on a work one.

---

## 2. What each posture changes (D2) — a named "teaching surface"

To keep learning mode from being a vague "explain more," it toggles a **closed, named set of behaviors**.
Everything else is identical between postures.

| Teaching-surface behavior | Delivery (default) | Learning |
|---|---|---|
| **Decision annotation** | decision recorded to the artifact (spec/task), no inline narration | inline one-liner as it happens: *what* was chosen, the *principle*, the *tradeoff* |
| **Principle citation** | none | names the doctrine + points to the owning pack/spec (e.g. "dumb-component law — `alva-adoption` §2") |
| **Alternatives shown** | rejected options live in the artifact only | the road-not-taken is surfaced briefly at the decision point |
| **Capture eagerness** (prefs/hurdles) | propose at natural pauses, 2nd-occurrence rule (unchanged) | propose more eagerly + explain *why it's worth remembering* |
| **End-of-unit digest** | outcome report only | a short **"what you learned"** recap: the 3–5 principles this unit exercised |
| **Pace / checkpoints** | as planned | may add a soft pause after a *teachable* checkpoint (never a hard gate) |

**Decision & reason:** a *bounded* teaching surface is the difference between a useful mode and an annoying
one — the user can predict exactly what changes, and it can't metastasize into narrating trivia. Anchoring
citations to the **packs/specs that own the principle** (G2) means learning mode is powered by the knowledge
layer, not by ad-hoc explanations the model improvises — the teaching is as correct as the pack. A free-form
"be more explanatory" posture (rejected) is unbounded and quickly becomes noise; tying teaching to real
doctrine keeps it honest and grounded.

---

## 3. Threading through the phases (D3)

Each phase skill reads `posture` (as it already reads `collaboration`) and adjusts *only* the teaching
surface (§2):

- **`idea-to-spec` (brainstorm):** learning mode explains *why* each design decision beats its alternatives
  as it's made (the spec already stores this; learning surfaces it live).
- **`spec-to-tasks` (plan):** learning mode explains the decomposition — why these checkpoints, why this is
  `[P]`, why this task carries this pack.
- **`task-execution` (execute):** learning mode annotates each priority-chain resolution and doctrine
  application inline, and gives the end-of-unit digest. Delivery mode stays quiet and fast.
- **`align-ui` / `visual-grounding` (design):** learning mode explains *which Nielsen heuristic* a state
  satisfies and *why native-over-custom* fired here.

**Decision & reason:** reusing the flag-reading pattern `collaboration` established means threading posture
costs each skill one small conditional, not a rewrite. Concentrating the visible teaching in `execute` +
`design` (where decisions are densest) rather than spreading equally keeps the volume proportional to where
learning actually happens.

---

## 4. Learning under `just-vibes` (D4) — teach the transcript, not a person

No human is present in an autonomous run, so learning posture can't narrate live. Instead:

- **The teaching digest is written, not spoken.** Learning + `just-vibes` appends a **"Lessons"** section to
  `.akios/just-vibes-journal.md` per unit: the principles exercised, the decisions and their *why*, and any
  captured hurdle/preference — the artifact a returning human reads to learn what happened *and why*.
- **Delivery + `just-vibes`** journals outcomes only (today's behavior).

**Decision & reason:** learning posture must still *mean something* unattended, or the flag silently no-ops
half the time. Redirecting the teaching to the journal turns "teach me" into "leave me a lesson log" — the
correct unattended analogue, and it composes with the deepthink "record every decision" rule (the journal
already exists; learning mode enriches it rather than inventing a channel).

---

## 5. Relationship to the rest of the family (D5)

- **Powered by G2 (knowledge packs):** every principle citation resolves to a pack/spec — learning mode is a
  *reader* of the knowledge layer, so better packs = better teaching.
- **Feeds G5 (hurdles/preferences):** learning mode is the natural moment to propose a capture *with its
  rationale* — it's already explaining the *why*, so proposing "remember this?" is one step further.
- **Independent of G6 (review):** review runs the same in both postures; learning mode only *explains* a
  review finding more, it never relaxes the gate.

**Decision & reason:** wiring posture to the packs and the capture loop is what makes it more than a verbosity
knob — it becomes the pedagogical face of the whole kit-evolution family. Keeping it independent of the
*quality* gates (review/verify) is a hard line: a mode must never trade correctness for pedagogy.

---

## 6. Worked example — the *Squad* slice, both postures

- **Delivery:** akios builds `PlayerRow` as a dumb component, resolves the persistence-key naming from
  `preferences.md`, converges the screen against the prototype, ships. The report says *what* shipped.
- **Learning:** at `PlayerRow` it notes *"built dumb (data + closures via `init`) — maximizes preview + test;
  tradeoff: the screen owns the VM (`alva-adoption` §2)."* At naming it says *"used your `preferences.md`
  rule 'namespace UserDefaults by feature' — tier 3 beat the swift-dev default."* At the `Gauge` it cites
  *"native-over-custom (B2): `Gauge` over a hand-drawn ring."* End-of-unit digest lists the 4 principles the
  Squad slice exercised, and proposes remembering a hurdle it hit ("SwiftData `@Model` + `Sendable` needs …").
- Identical `Squad` code in both; only the narration + capture eagerness differ.

---

## 7. Empty / edge states

- **No posture flag (pre-existing repo):** absent = `delivery`; zero behavior change until the user opts in.
- **Learning mode but nothing teachable in a unit** (a trivial mechanical task): no forced lesson — the
  digest can say "routine; no new principles" rather than manufacture a lecture.
- **Session override vs Roadmap default conflict:** the session override wins for the session and does *not*
  rewrite `Roadmap.md` (a spoken "just ship it" shouldn't silently flip the project's default).
- **Team mode + learning:** each instance teaches in its own session/journal; posture is per-instance, not a
  shared Roadmap value teammates fight over (it lives beside `collaboration` but, unlike status, isn't
  monotonic-merged — it's advisory).

---

## 8. Open / next

- **[CONSEQUENCE — to implement]** `Roadmap.md` template + `/akios:init` interview gain `posture`; `AGENTS.md`
  documents the teaching surface (§2) as a house behavior.
- **[CONSEQUENCE — to implement]** each phase skill (`idea-to-spec`, `spec-to-tasks`, `task-execution`,
  `align-ui`) reads `posture` and toggles the teaching surface; `just-vibes` gains the journal "Lessons"
  section under learning.
- **[CONSEQUENCE — to implement]** session-override parsing (`--learning` / `--delivery` + the spoken
  switches) that doesn't rewrite the Roadmap default.
- **[OPEN — revisit after first use]** whether learning mode should default *on* for a `mode: new` project (a
  first-time user likely wants to learn) — deferred until the flag has real-world signal.
