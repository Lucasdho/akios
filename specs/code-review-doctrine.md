# akios — Code-Review Doctrine
**Working spec · v1.0 · kit-evolution family · 2026-06-30**

Gives akios's review gate a **principled, architecture-aware checklist** instead of a generic pass: SOLID,
DRY, and ACID applied *honestly* to Swift/iOS, plus **ALVA + UI-doctrine conformance** and the **folder /
single-responsibility drift** that is the backlog's loudest complaint. Crucially it is *ALVA-aware* — it
subordinates DRY to the evidence ledger (so it never nags "extract this" against ALVA's locality principle)
and scopes ACID to persistence (so it never cargo-cults transactions onto a view). Answers backlog **B11**
(ACID/DRY/SOLID in review), **B10** (files with >1 responsibility; no domain/feature folders), and **B12**
(feed the repo good practices). Complements `alva-adoption.md` (whose boundaries it enforces),
`swiftui-design-doctrine.md` (whose native/token rules it checks), and `task-execution.md` (the gate that
loads it). See `akios-backlog-map.md` (G6).

> **State:** designed

> **The shift:** the kit's "Claiming done" step calls the built-in `/code-review`, but with no akios-specific
> doctrine — so it can't catch a file doing three jobs, a slice reaching into another's internals, or an
> inline color literal, and a naive "apply SOLID/DRY" reviewer would actively *fight* ALVA (which says
> locality beats DRY for agents). This spec makes review **grounded in the architecture akios actually
> teaches**: the classic principles where they genuinely apply, deferring to ALVA where they'd otherwise
> conflict.

---

## 1. What ships (D1) — a doctrine reference the gate loads, not a replacement

- akios ships a **`review-doctrine` reference** (a knowledge reference under the `ios` pack, beside
  `swiftui-design-principles`) — the checklist below. The "Claiming done" gate (`task-execution` finish +
  `just-vibes` GATE) **loads it as context for `/code-review`**; the built-in review command is not replaced.
- Optional thin wrapper **`/akios:review`** = built-in `/code-review` + this doctrine pre-loaded + the
  ALVA/UI conformance checks, for a one-command principled pass.
- **Graduated severity**, not a wall: **block** on correctness + boundary violations; **warn** on
  style/DRY/structure that the human (or `just-vibes`) can accept with a note. Only the correctness class is a
  hard stop — consistent with "gates are guardrails, not walls" (Vision).

**Decision & reason:** `/code-review` is a maintained built-in; replacing it (rejected) is reinvention and
loses upstream improvements — akios's value is the *doctrine + conformance checks* it feeds in, which the
built-in has no reason to know. A reference-plus-optional-wrapper keeps the built-in authoritative while
making review akios-aware. Hard-blocking everything (rejected) would make review a wall and stall
`just-vibes`; graduating severity keeps correctness strict and taste advisory.

---

## 2. The principles, applied honestly (D2)

Each classic framework is applied *only where it earns its keep* in Swift/iOS — the backlog's own posture
("great for intermediate-to-large projects; overkill for simple things").

### 2.1 SOLID — the parts that bite in SwiftUI

| Principle | Concrete akios check | Class |
|---|---|---|
| **SRP** | a file/type does **one** job — the direct B10 check: flag a file holding >1 model/component/responsibility; flag a screen whose ViewModel lost cohesion (`ui-first-architecture` §4.1) | block (files) / warn (cohesion) |
| **DIP** | ViewModels depend on **repo protocols**, not concretes; concretes injected via factory/`init` (ALVA §5, UI A5) | block |
| **ISP** | a `contract/` exposes only what consumers need; a component's `init` isn't a god-bag of params | warn |
| **OCP/LSP** | applied lightly — flagged only on real violations (e.g. a subclass that breaks its protocol's contract); not enforced ceremonially | warn |

### 2.2 DRY — **deferred to the evidence ledger, never eager** *(the key reconciliation)*

- The review does **not** demand extraction on sight. ALVA's thesis is *locality > DRY for agent-maintained
  code* (ALVA §2, §6): consistent repetition is cheaper for an agent than an abstraction it must chase across
  files. So DRY here means: **flag a candidate only when the Foundation `usage-ledger.json` says a symbol
  crossed the rule-of-three threshold** (`alva-adoption` §3) — and even then it's a *promotion task
  suggestion*, not a review block.
- Two consumers of a leaf visual (a modifier) is a liberal promote (ALVA §6.2); behavior promotes only behind
  a contract at a high bar. The review reads the ledger; it never eyeballs "you repeated this, extract it."

### 2.3 ACID — **scoped to persistence only, never to UI** *(the honesty guard)*

- ACID is a property of *transactions*, not of iOS in general. The review applies it **only to data-layer
  tasks** (SwiftData / store writes): atomic multi-entity writes, consistent store state after a failed save,
  no partial-commit corruption, correct isolation for concurrent writes.
- It **refuses to cargo-cult ACID** onto a stateless view or a pure component — flagging a `View` for
  "atomicity" is a doctrine bug, not a finding. If a task has no transaction boundary, the ACID check is N/A
  and says so.

**Decision & reason:** this is where a generic reviewer would *damage* an akios codebase — eager DRY fights
ALVA, and ACID sprinkled on views is noise. Anchoring DRY to the ledger makes it deterministic and
ALVA-consistent (abstraction stays a measured task, not a gut call), and scoping ACID to persistence keeps it
a real correctness check exactly where data integrity matters. Applying all of SOLID uniformly (rejected)
over-ceremonializes OCP/LSP in a value-type UI world; applying DRY eagerly (rejected) is the single biggest
way to contradict the architecture the kit just adopted.

---

## 3. ALVA + UI conformance checks (D3) — the akios-specific findings

Beyond the classics, the review enforces the doctrines akios ships. These are the checks that make review
*akios-aware* and that directly answer B10.

| Check | Rule | Source | Class |
|---|---|---|---|
| **Slice shape** | a feature has `domain/data/presentation/contract/tests`; files sit in the right layer | `alva-adoption` §1 | warn→block on drift |
| **Boundary** | a slice imports only another slice's `contract/`, never its `domain/`/`data/` internals | ALVA §5, `alva-adoption` §4 | **block** |
| **Folder / SRP drift (B10)** | no file with multiple models/components/responsibilities; domain/feature folders used, not a flat dump | B10 | block (multi-responsibility) |
| **Dumb-component law** | a component takes data + closures via `init`; no `@Environment`/service/global inside it | UI A4 | block |
| **Native-over-custom** | a custom control carries its `// custom: native X can't do Y` justification | UI B2 | warn (missing justification) |
| **DesignSystem tokens** | no inline `.font(.system(size:))` / `Color(.x)` literals; use tokens + role modifiers | UI B1/B4 | warn |
| **Foundation-first** | a new helper/protocol was checked against `Foundation/` before being written | ALVA P6 | warn |

**Decision & reason:** these are the rules that were *invisible* to a generic reviewer and that the backlog
explicitly wants enforced (folder structure, dumb components, tokens). Making **boundary** and
**multi-responsibility** hard blocks targets the exact pains named in B10 ("files with >1 responsibility; not
using folders"); keeping token/justification warnings soft respects that a bespoke screen sometimes
legitimately breaks the rule (with a note). The checks read as a table so `/code-review` and a cold subagent
can both apply them mechanically.

---

## 4. How it plugs in (D4)

- **Loaded at the gate:** `task-execution`'s finish step and `just-vibes`' GATE step load `review-doctrine`
  before `/code-review`, and apply §3's checks against the diff. It is the **spec-conformance proof's review
  half** in `verification-and-learning-loop.md` (G5 §2).
- **Priority-chain consistent:** where a project decision or a user pack contradicts a doctrine check (tier 1
  or 2 beats the baseline), the project wins — the review flags the *deviation* for visibility but doesn't
  block on a rule the repo deliberately overrode (a TCA repo won't be blocked for not using ALVA slices).
- **Findings can become hurdles:** a *repeated* review finding is a 2nd-occurrence signal — it feeds the
  hurdles ledger (G5 §3) so the pattern gets prevented upstream, not just caught downstream.

**Decision & reason:** loading the doctrine at the existing gate (not a new phase) keeps the pipeline shape;
making it defer to the priority chain prevents the review from over-riding a repo's deliberate architecture
(the review is a *floor*, like `swift-dev`, not a mandate that beats project decisions). Routing repeated
findings to the ledger connects review to learning — a finding you keep hitting becomes a rule you stop
breaking.

---

## 5. Worked example — reviewing the *Squad* slice

- **Blocks:** `Purchase` imports `Squad`'s internal `PlayerRepository` → boundary violation (§3) → must import
  `Squad.contract`. A `SquadTypes.swift` holding `Player`, `SquadRowData`, *and* `PlayerRow` → multi-
  responsibility (B10) → split into `domain/Player.swift`, `presentation/Models/SquadRowData.swift`,
  `presentation/Components/PlayerRow.swift`.
- **Warns:** `PlayerDetail` uses `Text(...).font(.system(size: 28, weight: .bold))` → DesignSystem-token
  warning → `.textStyle(.hero)`. A hand-rolled toggle with no `// custom:` note → native-over-custom warning.
- **DRY (ledger, not eyeball):** `FormatCurrency` appears in Squad + Wallet + Invoice → the ledger flags it at
  count 3 → review *suggests a promotion task* (not a block) to `Foundation/Code-tokens`. A helper repeated in
  only Squad → **no finding** (locality > DRY; below threshold).
- **ACID:** the roster-import task writes 20 `Player`s in one save → ACID check applies: atomic write, store
  consistent on failure. The `SquadListView` task → ACID N/A (no transaction), correctly silent.

---

## 6. Deliberate exclusions

- **No eager DRY.** Extraction is ledger-driven only (§2.2) — the review never says "you repeated this, DRY it"
  below rule-of-three. This is a hard line against contradicting ALVA.
- **No ACID on non-transactional code** (§2.3) — a view/component is never flagged for atomicity.
- **No blocking on a deliberately-overridden doctrine** — a project decision (tier 1) or user pack (tier 2)
  that supersedes a baseline check downgrades it to a visibility note, not a block.
- **No replacement of built-in `/code-review`** — akios feeds it doctrine; it doesn't fork it.

---

## 7. Empty / edge states

- **Non-ALVA repo** (e.g. TCA, or a pre-existing app): the ALVA/UI conformance checks (§3) are advisory
  visibility notes, not blocks — the review still applies SOLID/DRY-via-repeat/ACID and the folder/SRP check,
  which are architecture-agnostic. akios doesn't force ALVA onto a repo that chose otherwise.
- **Plugin/docs repo (this repo):** the Swift checks are N/A; review degrades to the DoD audit (grep for
  orphaned refs, YAML validity, install smoke-test) per `Roadmap.md` project-type. The doctrine says so rather
  than inventing Swift findings.
- **Ledger absent** (DRY check can't run): DRY degrades to *silent* (never eager-eyeball) — no ledger means no
  promotion suggestions, not a fallback to gut-feel extraction.
- **A finding the human disputes:** it's a warn (or a project override) — recorded, not forced; a *repeated*
  dispute is a signal the doctrine or a project decision needs updating (routed to the ledger, G5).

---

## 8. Open / next

- **[CONSEQUENCE — to implement]** `review-doctrine` reference under the `ios` pack (§1); the checklist tables
  (§2/§3) as its body.
- **[CONSEQUENCE — to implement]** `task-execution` finish + `just-vibes` GATE load the doctrine before
  `/code-review` and apply §3; optional `/akios:review` wrapper command.
- **[CONSEQUENCE — to implement]** the DRY check reads `Foundation/usage-ledger.json` (depends on
  `alva-adoption` §3 shipping the ledger) — until then DRY is silent, not eager.
- **[COMPOSES WITH]** `verification-and-learning-loop.md` (G5) — review is the spec-conformance proof's review
  half; repeated findings feed the hurdles ledger. `operating-modes.md` (G4) — learning posture explains a
  finding's principle; it never relaxes the gate.
- **[OPEN — tune after use]** the block/warn line for slice-shape drift (§3): how much structural drift is a
  hard stop vs. a note, calibrated against real repos.
