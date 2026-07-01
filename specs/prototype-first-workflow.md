# akios — Prototype-First Visual Workflow
**Working spec · v2.0 · UI overhaul annex (spec 1 of 3)**

Defines how akios takes a feature from "context gathered" to "a beautiful SwiftUI screen we
trust" by generating and remixing **multiple SwiftUI `#Preview` variations directly**, instead of
routing through an external visual medium and translating it. Introduces one new skill
(`ui-variations`) and folds approval into the existing `design` phase. First of a 3-spec UI
overhaul family: **`prototype-first-workflow` → `ui-first-architecture` → `swiftui-design-doctrine`**
(designed in order C → A → B). Everything here is settled unless marked *open*.

> **State:** designed

> **v2.0 changelog:** full pivot, replacing v1.0's HTML/Tailwind-first loop. Xcode 27's agent +
> Preview tooling makes SwiftUI itself the cheap, live-iterable medium — so there is no longer a
> reason to detour through HTML and translate back. `prototype`, `html-to-swiftui`, and
> `visual-grounding` are retired from the active build (none had shipped); `figma-to-swiftui`
> (which had shipped) is parked, not deleted. One new skill, `ui-variations`, owns the whole loop.
> New nested component/screen folder convention (§3) — carries as a consequence into
> `ui-first-architecture.md` (Block A), resolved in a follow-up session. Driven by two grounding
> documents supplied by the user: Apple's Xcode 27 agent-workflow guide and its SwiftUI
> prototyping-with-Previews companion (2026-07-01).

Worked example threaded throughout: **futebol-manager** — a football-manager iOS app, designed
UI-first, that starts with `deep-brainstorm` and builds every screen through the variation/remix
loop below (no external HTML/Figma files this time).

---

## 1. The medium (C1) — SwiftUI `#Preview`, generated in place; Figma/Stitch/HTML parked

**Decision:** the design phase generates prototypes **directly in SwiftUI**, as named `#Preview`
blocks, built from what already exists in the project: `PresentationLayer/DesignSystem/` tokens,
promoted `PresentationLayer/Components/`, and copy-and-adapt snippets from `snippet-library.md`
(`Foundation/Design-tokens`, per ALVA). The **primary** way a `DesignSystem` or a component comes
into being is direct agent-assisted code generation — conversation in the Xcode chat / terminal —
not an external design tool.

**Figma / Stitch / HTML are parked, not built into this loop.** They have real value (Figma's MCP
path already extracts structured tokens+layout) but wiring them in — even as an optional
background feeder into `Foundation/Design-tokens` + `references/*.md` — is deferred to a future
session. Nothing here blocks reviving that path later; it is simply not part of what gets built
now.

**Decision & reason:** Xcode Previews render live without a full rebuild — the exact property
that made HTML/Tailwind attractive in v1.0 (cheap, fast-feedback, human-iterable) — so routing
through a second medium and translating back no longer buys anything; it only adds a translation
step and the cross-engine rendering mismatch v1.0 had to work around (§5). Standardizing on
Figma/Stitch as the primary input (rejected) reintroduces a dependency on external tools for a
strategy that is now "100% focused on Xcode." Building the optional-ingestion path now anyway
(rejected, considered in the prior session) — no dependency forces it; better to ship the core
loop first and revive ingestion when it's actually wanted.

---

## 2. Generation & remix mechanics (C2) — bounded defaults, user override, sample data with edges

**Two rounds, one skill (`ui-variations`, §4):**

| Round | Default count | Produces |
|---|---|---|
| **Explore** | 3–5 named `#Preview`s | divergent styles from one prompt (features + mood/style params), each a runnable variation built from existing components/tokens/snippets |
| **Remix** | 3 named `#Preview`s | hybrids combining the specific elements the user liked across the explore round (e.g. "the typography from A, the layout from B") |

- **User-specified count wins.** If the user states a quantity for either round, `ui-variations`
  uses it — the defaults above are just what fires when they don't.
- **Edge-case guard:** on a quantity far outside a reasonable range (the user's own examples: 1 or
  100), the agent **warns, doesn't block** — states plainly that 1 defeats the anti-anchoring
  purpose of exploring at all, and that 100 spends heavily for marginal signal — then proceeds with
  what the user actually asked for once they confirm.
- **Sample data ships with every explore round**, in its own file, covering the edge cases a real
  screen will hit: empty state, unbounded/large data (100+ items), and long-text truncation — per
  the grounding doc's "Estratégia 2." This is not a separate skill or step; it is a required output
  of the same generation pass, so every variation is judged against real-shaped data, not
  best-case mocks.

**Decision & reason:** fixed small defaults (3–5 / 3) match what the grounding docs recommend and
keep cost predictable without a human specifying anything; a hard cap (rejected) fights the user
when they have a real reason to want more or fewer; no default at all (rejected) forces a question
on every single design-phase run for no benefit in the common case.

---

## 3. Approval & graduation (C3) — the winner lands in place; losers stay compilable in scratch

- **The approved variation graduates directly into its final file** — no translation step, because
  it is already the target code. It lands at:
  ```
  Features/<Feature>/<View>/<View>View.swift        ← next to its ViewModel
  Features/<Feature>/<View>/components/<Component>/  ← view-local components
  ```
  *(New nested-by-view convention — supersedes `ui-first-architecture.md`'s current
  `Features/<Feature>/Components/` + `Screens/<Screen>/` shape. That spec's A1/A2 need the matching
  update; tracked as the next block, not resolved here — see Open/Next.)*
- **Everything that didn't win** — the rest of the explore round, the remix losers — is archived to
  a **scratch file that still compiles and still previews**: `./scratchs/<Component-or-View>.swift`
  at the project root. Nothing is silently deleted at approval time.
- **Cleanup is manual or agent-assisted, never automatic.** The developer deletes a scratch file by
  hand, or asks the agent to. No background job prunes `./scratchs/`.
- **Unattended (`/akios:just-vibes`):** `ui-variations` auto-selects its best explore-round
  variation without waiting for a remix round (there's no one to state taste preferences to), marks
  it `[auto]`, and records the rationale — mirroring how `align-ui` already behaves unattended.

**Decision & reason:** graduating straight into place (no separate `prototypes/` approval
artifact, unlike v1.0) is possible *because* the medium is already the target medium — there is
nothing left to converge later. Keeping losers in a compiling scratch file (rejected: delete
immediately) preserves "why this one won" as a paper trail the user can actually look at (a real
file with real previews beats a git-log entry), without the overhead of a `manifest.md` (rejected:
full ceremony) for what is, ultimately, an aesthetic choice.

---

## 4. Skill inventory (C4) — one skill: `ui-variations`

| Skill | Owns | Phase |
|---|---|---|
| `ui-variations` | explore round, remix round, approve-and-graduate, archive-losers-to-scratch, sample-data-with-edge-cases | `design` |

**Retired from the active build — parked, not deleted, real value preserved for later:**

- `prototype`, `html-to-swiftui`, `visual-grounding` — never shipped (confirmed: not present in
  `skills/`). Their planned jobs are fully superseded by §1–§3 above; nothing is lost by not
  building them.
- `figma-to-swiftui` — **did** ship, stays exactly as it is today, just **not routed through this
  loop**. Its structured MCP token/layout extraction remains a real asset for a future session that
  wants to wire Figma/Stitch back in as an optional feeder (§1).

**Decision & reason:** one skill owning the whole design-phase loop is possible precisely because
there's no longer a translator/grounder pair to keep separate from a generator — collapsing what
was three skills into one isn't a shortcut, it's what falls out of removing the cross-medium
translation this family existed to manage in v1.0.

---

## 5. Deliberate exclusion — no cross-engine convergence loop

v1.0's `visual-grounding` existed to solve one problem: a SwiftUI render and an HTML render come
from different engines and are never pixel-identical, so convergence needed an agent-driven
structured diff. **That problem no longer exists** — the approved variation *is* SwiftUI, so there
is nothing to diff it against.

One narrower question survives: after `execute`'s make-it-live stage wires the real ViewModel and
real data, does the **real-data render** still hold up against what the **mock-data-approved**
variation looked like? (E.g., the mock tested a 100-player roster; does the real 150-player roster
still look right?) This is a same-engine, same-code check — much lighter than v1.0's cross-engine
diff — and it belongs to `align-ui`, which already owns states/interactions/navigation in the
design phase (§6). No new skill for it.

---

## 6. Pipeline integration (C6) — `design` keeps its job, the job's substance changes

Pipeline shape is unchanged (still 4 phases):

```
brainstorm  →  plan  →  design          →  execute
(specs)        (tasks)   (ui-variations:    (make-it-live:
                          explore+remix+     wire ViewModel,
                          graduate,          pull data JIT,
                          align-ui gaps)     align-ui post-wiring check)
```

- **`design` runs per spec/slice**, same as v1.0: it produces approved, graduated screens/
  components for that spec, then hands off to `execute`.
- **The "hard gate" concept collapses into `ui-first-architecture.md`'s existing build-order law
  (A3: components → dumb screen → make-it-live).** There is no separate approval mechanism to
  implement — a screen simply cannot enter make-it-live until its `ui-variations` round has
  graduated a winner into place, which *is* A3's ordering already.
- **`align-ui`** keeps its existing design-phase scope (states / interactions & gestures /
  navigation + JIT DTO shape) and **absorbs** the one surviving question from §5 (does real data
  break the approved look).
- **`execute`** runs make-it-live directly on the graduated screen — no translation skill, no
  grounding skill, per feature.

**Decision & reason:** unchanged from v1.0's reasoning for *why* a distinct `design` phase exists
(makes the UI-approval checkpoint a first-class stop, not interleaved with coding) — only the
mechanism inside it changed. See prior-session decision record: keeping `design` distinct (chosen)
over collapsing it into `execute` (rejected — loses the checkpoint) or making it conditional/
optional per screen (rejected — introduces a subjective "does this need it" judgment call other
specs would have to account for).

---

## 7. Worked example — futebol-manager, *Squad* feature

1. **brainstorm** — `deep-brainstorm` maps the whole app, bursts specs per surface area.
2. **plan** — `spec-to-tasks` produces the backlog for the *Squad* screen spec.
3. **design** — `ui-variations` runs the explore round on `SquadListView`: 4 named previews
   (`#Preview("Cozy")`, `#Preview("Editorial")`, `#Preview("Standings")`, `#Preview("Minimal")`),
   built from the existing `PlayerRow`/`FormBadge` snippets + `DesignSystem` tokens, each paired
   with `SquadSampleData.swift` covering an empty squad, a 100+-player roster, and a very long
   player name. The developer likes the typography from `Editorial` and the standings-board layout
   from `Standings` → remix round produces 3 hybrids. The developer approves one; it graduates to
   `Features/Squad/SquadList/SquadListView.swift` (next to `SquadListViewModel.swift`), with
   `Features/Squad/SquadList/components/PlayerRow/`. The other 6 variations (4 explore + 2 losing
   remixes) land in `./scratchs/SquadListView-variations.swift`. `align-ui` then resolves the
   non-visual gaps: empty-squad state, loading state while roster fetches, error/offline state,
   row-tap navigation, and the JIT DTO shape (`SquadRowData`).
4. **execute** — make-it-live attaches `SquadListViewModel(playerRepo:)` via `init`, pulls real
   players JIT. `align-ui`'s post-wiring check confirms the real 150-player roster (once actual
   data lands) still reads the way the 100+-player mock did — no separate translation or grounding
   pass needed.

The other screens (*Match Day*, *Player Detail*) repeat the same `design → execute` path — there is
no longer a "bring-it vs generate" fork, since every screen is built the same way now.

---

## 8. Empty / edge states (of the workflow itself)

- **No components/snippets exist yet for a genuinely novel screen:** `ui-variations` still
  generates freeform, but the explore round is lower-confidence with nothing established to draw
  from — the agent may suggest running snippet/knowledge ingestion first if the developer wants
  faster convergence (the parked §1 future-work path).
- **Extreme quantity requested (1 or 100):** warn per §2, then honor the explicit request once
  confirmed — never silently clamp.
- **Nothing from either round is liked:** don't force a remix out of parts nobody wanted. Ask the
  developer for fresh direction in their own words and regenerate the explore round instead.
- **`./scratchs/` grows stale over many design-phase runs:** no automatic pruning; flagged as an
  open UX question for a future `init`/hygiene pass (see `G10 init-reliability-and-ux.md` in
  `akios-backlog-map.md` — same footprint-hygiene concern, different files), not solved here.
- **Approved variation breaks once real data is wired:** handled as a normal `execute`-phase fix
  under `align-ui`'s post-wiring check (§5/§6) — not a re-triggered design-phase approval cycle.
- **Unattended (`just-vibes`):** auto-select-and-graduate from the explore round per §3, `[auto]`
  marked, rationale recorded in the scratch-file archive.

---

## 9. Open / next

- **[OPEN — next block this session] `ui-first-architecture.md` (Block A):** A1/A2 need the nested
  `Features/<Feature>/<View>/{components/, <View>View.swift}` convention from §3 in place of the
  current `Features/<Feature>/Components/` + `Screens/<Screen>/` shape; A3's build-order wording
  ("converges against the approved prototype") needs updating since convergence is now built-in,
  not a separate step.
- **[CONSEQUENCE — to implement]** `workflow.yml` / `pipeline.md`: `design` phase description
  changes (generates/approves via `ui-variations`, not HTML) — phase count stays at 4.
- **[CONSEQUENCE — to implement]** `align-ui` SKILL.md: add the post-wiring real-data-vs-mock
  check (§5) alongside its existing states/interactions/navigation/DTO scope.
- **[CONSEQUENCE — to implement]** `install-skills.sh`: `SKILLS=(...)` array gains `ui-variations`
  only.
- **[CONSEQUENCE — to implement]** `/akios:init` + `templates/`: scaffold `./scratchs/` at the
  project root; note in `Context.md` that it stays out of the Xcode target (same posture as v1.0's
  `prototypes/` note).
- **[CONSEQUENCE — to implement]** `ui-overhaul-implementation.md`: Phase 1 rewritten around
  `ui-variations` only; Phase 2's `align-ui`/`figma-to-swiftui` items adjusted to match; Phase 4
  scaffolding updated for `./scratchs/` instead of `prototypes/`.
- **[FUTURE — parked, not scheduled]** `figma-to-swiftui` repurposed as an optional
  tokens/components/references feeder (prior-session direction, not built this round);
  `prototype` / `html-to-swiftui` / `visual-grounding` retain documented value if a future session
  wants a non-Preview-native input path back.
- **[FUTURE — parked, not scheduled]** Tuning panels for animation/interaction parameter refinement
  (grounding doc's "Estratégia 3") — not part of this workflow; candidate for its own future
  micro-spec once interaction/animation work becomes a priority.
- **Block A dependency:** the folder convention (§3) and the build-order law it feeds are defined
  in `ui-first-architecture.md` — resolved next.
- **Block B unaffected:** `swiftui-design-doctrine.md` was audited against this pivot and needs no
  changes — it's medium-agnostic token/craft doctrine already.
