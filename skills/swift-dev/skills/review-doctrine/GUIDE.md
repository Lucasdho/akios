---
name: review-doctrine
description: Principled review checklist for akios's "Claiming done" gate — SOLID/DRY/ACID applied honestly to Swift/iOS, plus ALVA + UI-doctrine conformance and folder/SRP drift. Loaded by task-execution's finish step and just-vibes' GATE step before /code-review; not a replacement for the built-in command.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Review Doctrine — akios-aware `/code-review`

Full design: `specs/code-review-doctrine.md`. This guide is the checklist itself — the reference
`task-execution`'s finish step and `just-vibes`' GATE step load as context for the built-in
`/code-review`. It does not replace `/code-review`; it feeds it doctrine the built-in command has
no reason to know on its own.

**Graduated severity, not a wall:** **block** on correctness + boundary violations; **warn** on
style/DRY/structure a human (or `just-vibes`) can accept with a note. Only the correctness class
is a hard stop.

## 1. SOLID — the parts that bite in SwiftUI

| Principle | Concrete akios check | Class |
|---|---|---|
| SRP | a file/type does **one** job — flag a file holding >1 model/component/responsibility; flag a screen whose ViewModel lost cohesion | block (files) / warn (cohesion) |
| DIP | ViewModels depend on **repo protocols**, not concretes; concretes injected via factory/`init` | block |
| ISP | a `contract/` exposes only what consumers need; a component's `init` isn't a god-bag of params | warn |
| OCP/LSP | applied lightly — flagged only on real violations (a subclass breaking its protocol's contract); not enforced ceremonially | warn |

## 2. DRY — deferred to the evidence ledger, never eager

Never demand extraction on sight. ALVA's thesis is *locality > DRY for agent-maintained code* —
consistent repetition is cheaper for an agent than an abstraction it must chase across files.

- **Read `Foundation/usage-ledger.json`** (produced by `scripts/alva-usage-ledger.sh`; you read
  it, you never count usage yourself by grepping the repo). Flag a DRY candidate **only** when the
  ledger's `candidates_promote` says a symbol crossed the rule-of-three threshold
  (`alva-adoption.md` §3) — and even then it's a *promotion task suggestion*, never a review block.
- Two consumers of a leaf visual (a modifier) is a liberal promote; behavior promotes only behind
  a contract at a high bar.
- **Ledger absent or the entry isn't there:** DRY is **silent** — no promotion suggestion, never a
  fallback to gut-feel "you repeated this, extract it."

## 3. ACID — scoped to persistence only, never to UI

ACID is a property of *transactions*, not of iOS in general.

- **Applies only to data-layer tasks** (SwiftData / store writes): atomic multi-entity writes,
  consistent store state after a failed save, no partial-commit corruption, correct isolation for
  concurrent writes.
- **Never cargo-cult ACID onto a stateless view or pure component.** If a task has no transaction
  boundary, the check is **N/A** and says so plainly — flagging a `View` for "atomicity" is a
  doctrine bug, not a finding.

## 4. ALVA + UI conformance checks — the akios-specific findings

| Check | Rule | Class |
|---|---|---|
| Slice shape | a feature has `domain/data/presentation/contract/tests`; files sit in the right layer | warn→block on drift |
| Boundary | a slice imports only another slice's `contract/`, never its `domain/`/`data/` internals | **block** |
| Folder / SRP drift | no file with multiple models/components/responsibilities; domain/feature folders used, not a flat dump | block (multi-responsibility) |
| Dumb-component law | a component takes data + closures via `init`; no `@Environment`/service/global inside it | block |
| Native-over-custom | a custom control carries its `// custom: native X can't do Y` justification | warn (missing justification) |
| DesignSystem tokens | no inline `.font(.system(size:))` / `Color(.x)` literals; use tokens + role modifiers | warn |
| Foundation-first | a new helper/protocol was checked against `Foundation/` before being written | warn |

**Boundary** and **multi-responsibility** are the two hard blocks — they target B10's exact pains
(files with >1 responsibility; no domain/feature folders). Token/justification findings stay warns
— a bespoke screen sometimes legitimately breaks the rule, with a note.

## 5. Priority-chain deference — never a mandate over a project decision

Where a project decision (tier 1) or a user pack (tier 2) contradicts a doctrine check here, the
project wins. Flag the deviation for visibility; don't block on a rule the repo deliberately
overrode (e.g. a TCA repo isn't blocked for not using ALVA slices). This doctrine is a **floor**,
like `swift-dev` itself — never a mandate that beats project decisions.

## 6. Findings feed the hurdles ledger

A **repeated** review finding (the same check firing a 2nd time on the same kind of change) is a
2nd-occurrence signal — route it to `code-references/hurdles.md`
(`verification-and-learning-loop.md` §3) so the pattern gets prevented upstream, not just caught
downstream every time.

## 7. Empty / edge states

- **Non-ALVA repo:** §4's checks are advisory visibility notes, not blocks — SOLID/DRY-via-ledger/
  ACID and the folder/SRP check still apply (architecture-agnostic).
- **Plugin/docs repo (no Swift):** the Swift-specific checks are N/A; review degrades to the DoD
  audit (grep for orphaned refs, YAML validity, install smoke-test) per `Roadmap.md` project-type.
- **A finding the human disputes:** record as a warn or a project override, not forced; a
  *repeated* dispute routes to the hurdles ledger too — the doctrine or a project decision may
  need updating.

## Worked example — reviewing a *Squad* slice

- **Blocks:** `Purchase` importing `Squad`'s internal `PlayerRepository` (boundary) →
  `Squad.contract` instead. A `SquadTypes.swift` holding `Player` + `SquadRowData` + `PlayerRow`
  (multi-responsibility) → split by layer.
- **Warns:** `Text(...).font(.system(size: 28, weight: .bold))` → `.textStyle(.hero)`. An
  unjustified hand-rolled toggle → native-over-custom warning.
- **DRY (ledger, not eyeball):** `FormatCurrency` in Squad + Wallet + Invoice, ledger count 3 →
  *suggest* a promotion task to `Foundation/Code-tokens`. Same helper repeated only in Squad → no
  finding (locality wins, below threshold).
- **ACID:** a 20-`Player` roster-import save → applies (atomic write, consistent on failure). A
  `SquadListView` task → N/A, correctly silent.
