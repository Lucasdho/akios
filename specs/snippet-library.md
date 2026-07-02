# akios — Snippet Library (factory code seeds)
**Working spec · v1.0 · knowledge-architecture family · 2026-07-01**

Extends `knowledge-architecture.md`'s pack format with a second asset kind: literal, ready-to-use
Swift code (`kind: snippet`) alongside the existing prose (`kind: reference`). Where a reference
teaches a pattern, a snippet **is** the pattern — a native UI component, a repository CRUD template,
a gateway protocol, a design-system token file — copied into a project and adapted, not read and
re-derived from scratch. Lives as a **user-global pack** (`~/.claude/akios/knowledge/ios-factory/`),
not the shipped `ios` baseline, because this is the user's own curated "factory" code, not something
akios ships to everyone. Answers a new backlog item (**B30**, registered in `akios-backlog-map.md`
§11 of this spec). Complements `knowledge-architecture.md` (whose pack format, `--global` flag, and
priority-chain placement this reuses verbatim) and `alva-architecture-doctrine.md` /
`alva-adoption.md` (whose Design-tokens/Code-tokens split decides where a copied snippet lands).

> **State:** designed — mechanism only. Populating actual snippet content (which card, which
> repository pattern, etc.) is explicitly deferred; see §10.

> **The shift:** akios can already load *advice* about Swift/iOS (the `ios` pack's `references/*.md`,
> and any user pack ingested via `/akios:learn`). It cannot yet load *code the user already trusts* as
> a literal starting point. This spec is the small, additive change that lets a pack carry real
> `.swift` files the pipeline copies and adapts, instead of only prose it reads and imitates.

Worked example: **futebol-manager**, same as the ALVA family, so the specs compose without a second
translation layer.

---

## 1. Two mechanisms, not one (D1)

The user's original ask bundles two different things:

- **Snippets** — a reusable *piece* (a card component, a repository template, a use case, a gateway
  protocol, a design-system file). Consumed **during a task**, at whatever point `spec-to-tasks` /
  `task-execution` decide a piece of boilerplate is needed.
- **Skeletons** — a *whole project* starting tree, consumed **once, at `/akios:setup` time**, to give
  a oneshot a solid base instead of an empty scaffold.

**Decision & reason:** these solve problems at different radii (one file vs. an entire tree) and at
different pipeline moments (mid-task vs. project birth) — forcing them into one format would blur a
task-scoped lookup with a project-initialization choice. Keeping them separate lets each be designed
against what it actually does, and lets one ship without waiting on the other (§7).

**Priority (user-set):** snippets are being registered and built now; skeletons are sketched (§7) but
explicitly **not** a priority — the mechanism is described so it isn't lost, not so it gets built next.

---

## 2. Snippets are a pack extension, at user scope (D2)

A snippet is **not** part of the shipped `ios` baseline pack. It is the user's own curated code, so it
lives in a **user-global pack** — reusing the `--global` mechanism `knowledge-architecture.md` §5
already defined (`~/.claude/akios/knowledge/`, survives across repos).

- Working pack name: **`ios-factory`** (provisional — rename freely the first time content is
  actually registered; nothing downstream depends on the string).
- `baseline: false`, so it sits in **tier 2** of the priority chain (user-curated) and outranks the
  shipped `ios` pack (tier 4) wherever both speak — the user's own field-tested card wins over the
  baseline's generic advice by default, same rule `knowledge-architecture.md` §3 already set for any
  user pack.
- The pack format itself is unchanged (`pack.yml` + `INDEX.md` + `references/` + `skills/` from
  `knowledge-architecture.md` §2) — this spec adds one new sibling directory, `snippets/`, and one new
  `kind` value in `INDEX.md` rows.

**Decision & reason:** extending the existing pack format (rather than inventing a parallel
`snippets/<category>/` mechanism at the repo root) means "bring your own snippets" composes for free
with everything `knowledge-architecture.md` already decided — discovery, routing by tag/trigger, and
tier-2-beats-tier-4 precedence. A parallel mechanism would need its own discovery and precedence rules
duplicated from scratch, and would not benefit a *different* user pack (e.g. a DDD pack) that also
wants to ship a literal code example one day.

---

## 3. Consumption model — copy and adapt (D3)

`kind: snippet` is consumed differently from `kind: reference`:

| | `kind: reference` | `kind: snippet` |
|---|---|---|
| Format | prose `.md` | one or more `.swift` files + `usage.md` |
| Consumption | read as guidance; agent writes fresh code following the pattern | **copied verbatim**, then adapted (rename types/fields to the task's real entities) |
| Cost avoided | re-deriving the pattern from a description | re-deriving *and* re-writing boilerplate the user has already field-tested |

When `task-execution` resolves a task to a `kind: snippet` entry, it:

1. Copies the file(s) into the target location (§5 decides where).
2. Adapts placeholder names (e.g. `EntityName` → `Player`) per the snippet's `usage.md`.
3. **Prunes** anything the task doesn't need (an unused CRUD method, an unused field) — this is a
   required DoD step, not optional, so a copied template doesn't leave dead code behind.

**Decision & reason:** the entire point of registering a snippet is to skip rewriting boilerplate from
scratch every time a repository or a card is needed — reading it "as inspiration" and writing fresh
code anyway (the same model as `references/*.md`) would throw away exactly the savings the user is
asking for, and would drift from the field-tested original over repeated re-derivations.

---

## 4. Snippet shape — bundles, not always single files (D4)

A repository template needs more than one file to be useful: the protocol, the concrete
implementation, and — per the user's explicit ask — an example of how it's wired into a ViewModel. A
single-file-per-entry format can't represent that without an artificial split.

```
~/.claude/akios/knowledge/ios-factory/
  pack.yml
  INDEX.md
  snippets/
    player-row-card/
      PlayerRowCard.swift
      usage.md
    repository-swiftdata-crud/
      Repository.swift              (protocol)
      RepositoryImpl.swift          (SwiftData concrete)
      usage.md                      (ViewModel usage example + adaptation notes)
    repository-supabase-crud/
      Repository.swift
      RepositoryImpl.swift
      usage.md
    usecase-fetch-and-cache/
      FetchAndCacheUseCase.swift
      usage.md
    gateway-protocol/
      GatewayProtocol.swift
      usage.md
    design-system-template/
      DesignSystem.swift
      TextStyle+ImageStyle.swift
      usage.md
  sources/                          (optional — raw originals, for provenance/re-ingestion)
```

**Decision & reason:** `snippets/<name>/` is always a folder, even for a single-file case (a lone
card component still gets its own folder with one `.swift` + `usage.md`) — one shape for every entry,
no branching between "simple" and "bundle" snippets. This is the same "convention as compression"
instinct ALVA already uses for feature slices (§103 of `alva-architecture-doctrine.md`): the agent
learns one shape and reproduces it, instead of two.

`usage.md` is mandatory per snippet and covers: what to rename/adapt, what to wire (DI registration,
Router entry, etc. if applicable), and any companion file it depends on.

---

## 5. Target placement — Foundation vs. feature-local, declared per snippet (D5)

ALVA already splits shared code into two drawers with **different sharing rules** (§6.2 of
`alva-architecture-doctrine.md`): **Design-tokens** (leaf, visual, promote liberally) and
**Code-tokens** (behavior, high bar, promoted only behind a contract with evidence). A card snippet
and a repository snippet should not land in the same place by default.

Each snippet's `usage.md` (or a `target:` field in its `INDEX.md` row) declares one of:

- **`Foundation/Design-tokens`** — for snippets that are visual and meant to be shared from day one
  (the card component, the design-system template). Copied there directly; no per-feature adaptation
  needed beyond wiring.
- **`Features/<F>/data|domain`** — for snippets that carry behavior and are inherently per-feature (a
  repository template, a use case, a gateway protocol). Copied fresh into *each* feature that needs
  one, with entity names adapted per feature. It does **not** get pre-placed in `Foundation/`.

**Decision & reason:** this mirrors the ALVA split exactly, and matters in practice — copying a
shared UI leaf into every feature that touches it (waiting for the usage-ledger to notice and promote
it) would leave the card duplicated across the first two features for no reason, since the user has
already declared it's meant to be shared. Copying a repository straight into `Foundation/Code-tokens`
would do the opposite: it would pre-declare every entity's data access as "central domain," which is
exactly the high-blast-radius shortcut ALVA's evidence-based promotion exists to prevent.

**Noted tension (resolved, not reopened):** ALVA D11 says Foundation promotion must be *suggested* by
the ledger, never automatic or silent — a snippet declaring `target: Foundation/Design-tokens` looks,
at first glance, like a silent bypass of that rule. It is not: the ledger's lifecycle governs code that
is **written organically inside a feature** and later graduates on evidence. A snippet's target is a
decision the **human already made at registration time** (during the `/akios:learn --kind snippet`
confirm-before-live step, §6) — a second, explicit entry point into Foundation, not a mutation of the
ledger's own promotion/demotion rules. The ledger is untouched; it still governs everything that isn't
a registered snippet.

---

## 6. Ingestion tooling — `/akios:learn --kind snippet` (D6)

Extends the ingestion skill/command `knowledge-architecture.md` §5 already designed
(`knowledge-ingest`, `/akios:learn`), rather than adding a new command:

```
/akios:learn <file-or-folder> --pack ios-factory --kind snippet --global
```

Behavior, layered on top of the existing ingestion pipeline (§4 of `knowledge-architecture.md`):

1. **Skips distillation.** Unlike a `kind: reference` ingest (which chunks and distills into prose),
   a snippet copies the source file(s) **verbatim** into `snippets/<derived-name>/`.
2. **Drafts, doesn't finalize.** Writes a draft `INDEX.md` row (name, tags guessed from path/filename)
   and a stub `usage.md` — the user fills in the adaptation notes and the `target:` (§5) before
   confirming.
3. **Same propose-before-live gate** as any pack ingestion (`knowledge-architecture.md` §4 step 4):
   shows the draft, waits for confirmation, never silently goes live — a wrong `target:` is exactly the
   kind of mistake that should be caught by a human, since it can misplace behavior into `Foundation/`.
4. **Provenance kept** in `pack.yml` (source path, ingestion date) and, optionally, `sources/` — same
   as any other pack, so a snippet can be re-ingested if the original file changes.

**Decision & reason:** reusing `/akios:learn` rather than a bespoke command means this spec adds one
mode to existing plumbing (skip the distillation step for code) instead of a second ingestion system —
consistent with how `knowledge-architecture.md` itself avoided a bespoke pack format for `swift-dev`.

---

## 7. Skeletons — promoted to their own spec

Skeletons (whole-project starters, chosen once at `/akios:setup` time) were sketched here originally,
then promoted to a full spec once discussed enough to warrant one: see **`skeleton-library.md`**
(backlog B31, `akios-backlog-map.md` G8). Nothing in §1–§6 of this spec depends on it; the two ship
independently.

---

## 8. Worked example — futebol-manager

Two snippets registered in `ios-factory`:

- `player-row-card` (`target: Foundation/Design-tokens`) — a card showing a player's photo, name, and
  form badge.
- `repository-swiftdata-crud` (`target: Features/<F>/data`) — a SwiftData repository protocol +
  concrete + a `usage.md` showing it wired into a ViewModel via `init`.

Months later, building the `Squad` slice: `spec-to-tasks` tags the relevant tasks `pack:ios-factory`
(alongside `pack:ios`). `task-execution` resolves both:

- `player-row-card` is already sitting in `Foundation/Design-tokens/` (a prior feature registered it
  first) — nothing to copy, just import and use as `PlayerRowCard`.
- `repository-swiftdata-crud` is copied fresh into `Features/Squad/data/`; `EntityName` becomes
  `Player`, unused CRUD methods the Squad feature doesn't call are pruned, and `SquadListViewModel` is
  wired to it exactly as the snippet's `usage.md` demonstrated.

Both snippets, one pipeline pass, two different target rules — exactly what §5 predicts.

---

## 9. Empty / edge states

- **No `ios-factory` pack yet (first-ever ingestion):** `/akios:learn --kind snippet --global` creates
  `pack.yml` + `INDEX.md` + `snippets/` from scratch; no separate "init a pack" step needed.
- **Task could use a snippet, but none matches:** falls through silently — the agent writes fresh code
  as it would today. No error, no forced match; same graceful degradation
  `knowledge-architecture.md` §7 documents for "no user packs."
- **Copied snippet has parts the task doesn't need:** pruned as part of the DoD (§3 step 3) — a
  snippet copy is never accepted as-is without a prune pass.
- **Two packs both have a matching snippet** (e.g. `ios-factory`'s repository template and a separate
  `ddd` pack's repository pattern): same open item `knowledge-architecture.md` §7 already flags for
  within-tier conflicts — not re-solved here, just inherited.
- **Ingested source isn't valid/parseable Swift** (wrong path, a non-code file dropped by mistake):
  ingestion declines the entry rather than writing a broken file into `snippets/`.
- **Declared target folder doesn't exist yet in the consuming project** (e.g. `Foundation/Design-tokens`
  not scaffolded): created as part of the copy, same as any first-file-in-a-folder case.

---

## 10. Deliberate exclusions

- **No automatic Foundation promotion via the ledger for feature-local snippet copies.** A copied
  `repository-swiftdata-crud` stays feature-local until the *ledger* (an independent mechanism, ALVA
  §6) sees 2+ features actually share one — the snippet mechanism does not shortcut evidence-based
  Code-tokens promotion; only the declared Design-tokens path (§5) is a deliberate shortcut.
- **No skeleton build in this pass** — sketched (§7), explicitly deferred, not part of §11's backlog.
- **No content population.** This spec defines the mechanism only. Curating the actual snippets (which
  card, which repository pattern, which gateway protocol) is manual work the user is **explicitly not
  doing right now** — see §12.
- **No cross-project auto-sync.** A snippet copied into a project is a point-in-time copy; updating the
  registered snippet later does not retroactively update code already copied from it — same semantics
  as any template.

---

## 11. Backlog placement

Registered as **B30** in `akios-backlog-map.md` §1 (new backlog line, this session — not from the
original raw list), under a new theme **"Knowledge / starter content."** Added to §3 as **G7**:

| # | New spec | Answers | One-line thesis |
|---|---|---|---|
| G7 | `snippet-library.md` | B30 | Extend the pack format with literal, copy-and-adapt Swift snippets (components, repository templates, use cases, gateway protocols, design-system files), user-global, separate from skeletons. |

**Sequencing:** depends on `knowledge-architecture.md` shipping first (pack discovery, `--global`,
`INDEX.md`/`pack.yml` schema) — this spec only adds a `kind` value and a sibling directory to a format
that must already exist. Fits naturally right after `knowledge-architecture.md` in the recommended
build order (`akios-backlog-map.md` §5 step 4), before `skill-authoring.md` (step 5).

`Roadmap.md` gets a new row: `snippet-library.md` | domain "Factory code snippets seed (extends
knowledge-architecture packs)" | status `designed` | notes "backlog B30; depends on
knowledge-architecture.md; skeletons (§7) deferred, not in this build."

---

## 12. Open / next

- **[DEPENDS ON]** `knowledge-architecture.md` must ship (pack discovery/routing, `--global`, the
  `pack.yml`/`INDEX.md` schema) before `kind: snippet` has a format to attach to.
- **[CONSEQUENCE — to implement, once unblocked]** Extend `/akios:learn` with `--kind snippet` (§6):
  skip distillation, copy verbatim, draft the bundle + `usage.md`, confirm-before-live.
- **[CONSEQUENCE — to implement]** `task-execution` gains the copy-and-adapt-and-prune step (§3) for
  any task whose pack lookup resolves to a `kind: snippet` entry, and reads each entry's declared
  `target:` (§5) to decide `Foundation/` vs. feature-local.
- **[MANUAL WORK — explicitly deferred by the user]** Curating the actual snippet content. This spec
  only fixes the shape; populating `~/.claude/akios/knowledge/ios-factory/` is future work, done
  incrementally as the user chooses to register pieces.
- **[DEFERRED, low priority]** Skeletons (§7) — shape sketched, not scheduled.
- **[OPEN]** `ios-factory` is a provisional pack name — rename freely at first real registration.
- **[ASSUMES]** The ALVA-vs-layer-first fork (`akios-backlog-map.md` §4) resolves in ALVA's favor. This
  spec's `target:` vocabulary (`Foundation/Design-tokens`, `Features/<F>/data`) is ALVA's folder law —
  if that fork reopens against ALVA, this spec's target vocabulary needs remodeling too.
