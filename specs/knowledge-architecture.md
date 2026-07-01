# akios — Knowledge Architecture (packs + ingestion)
**Working spec · v1.0 · kit-evolution family · 2026-06-30**

Splits akios into two layers — a **domain-agnostic meta-prompt layer** (the pipeline machinery) and a
**knowledge layer** of pluggable **knowledge packs** — and defines how packs are *authored by ingestion*
from code, PDFs, images, books, and documents. Today Swift/iOS knowledge is hardwired into the spine
(`swift-dev` is *the* domain); this spec makes it *one pack among many* and lets a user grow new domains.
Answers backlog **B4** (abstract meta-prompts from domains), **B5** (upload skills/code/`.md` about an
area), **B6** (build knowledge `.md` from code/PDF/image/book/doc), and reinforces **B12** (feed the repo
good practices). Complements `preferences-and-priority.md` (whose `code-references/` mechanism this
generalizes) and `plugin-architecture.md` (the layer it factors). See `akios-backlog-map.md` (G2).

> **State:** designed

> **The shift:** akios's discipline (phases, gates, priority chain, the execution loop) is *general* — it
> has nothing to do with Swift. Its *knowledge* (SwiftUI patterns, SwiftData, concurrency) is Swift-specific
> and is currently welded to the machinery. This spec cuts that weld: the machinery becomes a substrate that
> loads **knowledge packs**, `swift-dev` becomes "the iOS pack," and the user can *build their own packs*
> from the material they already trust — code they like, a book, a PDF, a design system, a company's
> conventions. akios stops being an iOS tool that happens to be disciplined and becomes a **disciplined
> substrate that happens to ship iOS knowledge.**

Worked example: a user who wants akios to know **Domain-Driven Design** ingests a DDD book (PDF) + five
sample repos, producing a `ddd` pack the pipeline routes to whenever a task touches domain modeling.

---

## 1. The two layers (D1) — meta-prompt substrate vs. knowledge packs

Everything akios ships is reclassified into exactly one layer:

- **Meta-prompt layer (the substrate) — domain-agnostic.** The phase engines (`idea-to-spec`,
  `spec-to-tasks`, `task-execution`), the run-styles (`deep-brainstorm`, `just-vibes`), the gates, the
  priority chain, the folder/state lifecycle, `install`. None of it mentions Swift; it *routes to* whichever
  pack a task's domain selects.
- **Knowledge layer (the packs) — domain-specific.** `swift-dev` and its bundled guides
  (`swiftui-pro`, `swiftdata-pro`, `swift-concurrency-pro`, `swiftui-design-principles`, …) are re-cast as
  **the iOS knowledge pack**. `code-references/` is **the project's auto-built code pack** (§4). New packs
  (DDD, a company style guide, a specific design system, a backend domain) plug into the same slots.

**The seam:** the substrate calls a pack through three well-known hooks it already has, just generalized:

| Substrate hook (today) | Generalized to |
|---|---|
| `spec-to-tasks` tags each task with a `swift-dev` sub-skill | tags each task with a **`pack:domain`** (defaults to `ios:*` when the repo is Swift) |
| `task-execution` "load the task's swift-dev domain sub-skill by scope" | "load the task's **pack reference** by scope" |
| priority-chain tier 4 = `swift-dev` (baseline) | tier 4 = **baseline packs** (the shipped floor; `ios` is one) |

**Decision & reason:** the abstraction B4 asks for is real and cheap here because the substrate *already*
routes to `swift-dev` through a small, named set of hooks — generalizing "swift-dev" to "the selected pack"
touches those hooks and nothing else. Rewriting the phase engines to be domain-parametric from scratch
(rejected) is a huge refactor for the same result. Leaving Swift welded in and bolting domains on as ad-hoc
skills (rejected) is what akios does today — it doesn't scale past iOS and gives no ingestion story. Casting
`swift-dev` as *the first pack* means the pack format is validated by the kit's own most-used asset from day
one, not invented in the abstract.

---

## 2. The knowledge-pack format (D2)

A pack is a directory the substrate can discover, route to, and disclose progressively. It reuses the
`swift-dev` guide shape (already proven) plus a thin manifest:

```
knowledge/<pack-name>/
  pack.yml            → manifest: name, domain tags, triggers, version, provenance, baseline?:bool
  INDEX.md            → one line per reference: "<file> — what it teaches [tags]"  (progressive disclosure)
  references/*.md     → the distilled knowledge, one concern per file
  skills/             → OPTIONAL: behavior skills this pack ships (a pack can carry meta-prompt too)
  sources/            → OPTIONAL: the raw ingested material (PDF/images/code) kept for re-distillation + audit
```

`pack.yml`:
```yaml
name: ddd
domain_tags: [domain-modeling, architecture, bounded-context]
triggers: [aggregate, entity, value object, repository, ubiquitous language]   # phrase/tag matches that route to this pack
version: "0.1.0"
baseline: false        # true only for shipped floor packs (ios). user packs are false = they outrank baseline (§3)
provenance:            # where the knowledge came from — for audit + re-distillation
  - {source: "Evans-DDD.pdf", kind: book, ingested: 2026-06-30}
  - {source: "code-samples/", kind: code, ingested: 2026-06-30}
```

- **Discovery:** the substrate scans `knowledge/*/pack.yml` at session start (and `~/.claude/akios/knowledge/`
  for user-global packs), building a routing table from `domain_tags` + `triggers`. Cheap: manifests only.
- **Routing:** `spec-to-tasks` tags a task `pack:<name>` when its scope matches a pack's tags/triggers; a
  task may carry more than one pack tag (an iOS task modeling a domain gets `pack:ios` + `pack:ddd`).
- **Disclosure:** `task-execution` loads **only** the `INDEX.md`-selected reference file(s) for the task's
  domain — never the whole pack (the `code-references` INDEX discipline, `preferences-and-priority.md` §2,
  now applied to every pack).

**Decision & reason:** reusing the `swift-dev` guide+INDEX shape means packs inherit progressive disclosure
for free and `swift-dev` *becomes* a conforming pack with near-zero change. A bespoke pack format (rejected)
would need its own loader and wouldn't be dog-fooded. Bundling raw sources *inside* the pack (kept, optional)
costs disk but enables re-distillation when the format improves and keeps provenance auditable — a pack you
can't trace back to its source is a pack you can't safely update.

---

## 3. Priority-chain placement (D4) — packs generalize tiers 2 and 4

The locked 4-tier chain (`preferences-and-priority.md` §3) is *preserved* and generalized — no tier is added
or reordered; two tiers widen:

```
1. Project decision            (MEMORY.md + existing code / Context.md)              ← unchanged
2. Knowledge packs, user-curated  (code-references = the code pack; other user packs by tag)   ← widened
3. User preferences            (~/.claude/akios/preferences.md — transferable taste) ← unchanged
4. Baseline packs, shipped floor  (the `ios` pack = today's swift-dev; other baseline packs)    ← widened
```

- **`code-references/` is now the project's *code pack*** — the same INDEX-gated mechanism, reframed as one
  pack whose references are auto-built from uploaded Swift (§4). Other user packs (DDD, a design system) sit
  in the same tier 2: curated-by-the-user, concrete, project-or-user-scoped.
- **User packs outrank baseline packs** (tier 2 > tier 4) for the same reason concrete sample code already
  outranks the `swift-dev` default: the user curated it for *this* purpose. A user's DDD pack beats the iOS
  pack's generic advice on aggregate design; the iOS pack still answers everything the DDD pack is silent on.
- **`baseline: true`** marks a shipped floor pack (only `ios` today). User-ingested packs are always
  `baseline: false`, which is *why* they land in tier 2, not tier 4.

**Decision & reason:** the chain's whole point is "the most specific, most user-endorsed source wins, and
`swift-dev` is the floor that always answers" — packs slot into exactly that shape if user packs = the
specific/endorsed tier and baseline packs = the floor. Adding a new tier for packs (rejected) breaks a
*locked* decision and creates ambiguity about where packs sit relative to preferences; widening the two tiers
that already meant "curated" and "floor" is the minimal, conflict-free change. A weighted blend across packs
(rejected, same as the original Decision 3-B) is non-deterministic — strict cascade only.

---

## 4. Ingestion — building a pack from raw material (D3, answers B5/B6)

The `/akios:learn <source>` path (skill: `knowledge-ingest`, §5) turns material into a pack. It is
**source-typed** and **`oss-first`-routed** — akios does not hand-parse what a mature extractor already does.

| Source (B6) | Extraction (oss-first — use the real tool) | Distillation → `references/*.md` |
|---|---|---|
| **Code** (a repo, files the user likes) | index the code; pull representative patterns (the `code-references` path) | one reference per pattern + an INDEX row with domain tags; keep files in `sources/` |
| **PDF / book** | the `pdf` / `pdf-reading` skill → text + tables (OCR if scanned) | chunk by chapter/concept → distill each into a concept reference; cite page ranges in provenance |
| **Image / screenshot / diagram** | multimodal read (describe the artifact) | a reference capturing the described rules/structure (e.g. a design system's spacing from a spec image) |
| **`.md` / docs** (B5) | ingest directly | index as-is if already distilled; else re-distill to the one-concern-per-file shape |
| **A skill** (B5) | the user drops a `SKILL.md` | placed under the pack's `skills/` (a pack can ship behavior, §2) |

The pipeline, once material is extracted:

1. **Extract** with the source-typed tool (never hand-parse a PDF).
2. **Distill** each chunk into a `references/*.md` that follows the pack format — *one concern per file*,
   written as guidance the pipeline can act on, not a copy of the source.
3. **Index + tag** — write `INDEX.md` rows and `pack.yml` `domain_tags`/`triggers` so routing works.
4. **Propose, don't auto-adopt.** Ingestion is a *proposal*: it shows the drafted pack (INDEX + a sample
   reference) and asks to confirm before the pack goes live — the same **observe → confirm → append**
   discipline that governs `preferences.md` (`preferences-and-priority.md` §1). Under `just-vibes` the pack
   is auto-adopted with the rationale journaled (mirrors align-ui/prototype auto-approval).
5. **Retain provenance** in `pack.yml` + `sources/` so the pack can be re-distilled when the format improves.

**Decision & reason:** the backlog explicitly lists heterogeneous sources (code/PDF/image/book/doc) — a
single hand-rolled parser would be worse at each than the dedicated skills akios already has, so ingestion is
a *router* over those skills (this is `oss-first` applied to the kit itself). Distilling rather than
verbatim-copying is essential: a pack the pipeline loads under progressive disclosure must be *actionable
guidance*, and a 400-page book pasted in defeats disclosure and blows the context budget. Human confirmation
before a pack goes live prevents a bad ingest from silently poisoning tier 2 of the priority chain — a wrong
pack is worse than no pack because it *outranks* the baseline.

---

## 5. The ingestion skill + command (D5)

- **Skill `knowledge-ingest`** (authored via `skill-authoring.md`, G3) owns steps 1–5 of §4. It routes to
  `pdf`/`pdf-reading`/`docx`/multimodal/`oss-first` for extraction and writes the pack.
- **Command `/akios:learn <source> [--pack <name>] [--global]`** — thin wrapper. `<source>` is a path, a
  folder, or a URL; `--pack` targets/creates a named pack; `--global` writes to
  `~/.claude/akios/knowledge/` (user-global, survives repos) instead of the repo's `knowledge/`.
- **`swift-dev` is refactored into `knowledge/ios/` conceptually** (a `baseline: true` pack) — *the router
  and guides are not rewritten*, only re-manifested: add a `pack.yml` + generalize the routing hooks (§1). The
  guide files stay put; a compatibility note records that `swift-dev` == the ios pack.

**Decision & reason:** a distinct skill+command keeps ingestion off the build spine (it's a *maintenance*
action, like `/akios:init`, not a phase) and gives `just-vibes` a clean thing to call when it wants to learn
before building. Re-manifesting `swift-dev` rather than physically moving it avoids a large, risky file move
for a naming change — the pack abstraction is about *routing*, which a manifest provides without relocating
proven guides.

---

## 6. Worked example — a `ddd` pack from a book + samples

1. `/akios:learn ~/books/Evans-DDD.pdf --pack ddd` → the `pdf` skill extracts text; `knowledge-ingest`
   chunks by chapter and distills `references/{aggregates,bounded-context,ubiquitous-language,repositories}.md`.
2. `/akios:learn ~/code/ddd-samples/ --pack ddd` → the code path indexes the samples, adds
   `references/aggregate-example.md` + INDEX rows, and drops the files in `knowledge/ddd/sources/`.
3. `pack.yml` gets `domain_tags: [domain-modeling, bounded-context]`, `triggers: [aggregate, entity, value
   object]`, `baseline: false`. akios shows the drafted INDEX + one reference; the user confirms → pack live.
4. Later, planning the *Squad* slice, `spec-to-tasks` sees "define the Squad aggregate" → tags the task
   `pack:ios` + `pack:ddd`. `task-execution` loads `ios:swiftdata-pro` **and** `ddd:aggregates.md` — the
   aggregate is modeled the way the user's book teaches, persisted the way the iOS pack teaches. Because
   `ddd` is tier 2 and `ios` is tier 4, the DDD aggregate rules win where they speak; iOS fills the rest.
5. This composes with `alva-adoption.md`: ALVA's portable Part I can itself ship as a `baseline` architecture
   pack, so a non-Swift stack adopts the doctrine while a Swift repo also loads the `ios` realization.

---

## 7. Empty / edge states

- **No user packs (fresh repo):** tier 2 has only the (possibly empty) code pack; the chain falls through to
  the `ios` baseline exactly as today. Zero behavior change until the first pack is ingested.
- **A pack's trigger over-fires** (matches tasks it shouldn't): tighten `triggers`/`domain_tags` in `pack.yml`
  — routing is data, not code, so it's a one-line edit, not a skill change.
- **Two user packs conflict** on the same task (both tier 2): the chain is silent on *within-tier* order, so
  `task-execution` records the conflict as an open item and picks the pack whose `triggers` matched more
  specifically, noting it — never blends. (Refine to explicit pack precedence if this bites; flagged §9.)
- **Ingested source is huge / low-signal:** distillation caps each reference at a disclosure-friendly size;
  if a source yields nothing actionable, ingestion says so and writes no reference rather than padding.
- **Non-Swift repo:** the substrate still runs; there's just no `ios` baseline routing until an appropriate
  baseline pack is present (`akios` degrades to "disciplined substrate with the user's packs only").

---

## 8. Deliberate exclusions

- **No verbatim source dumping into references** — always distill; the raw source lives in `sources/`, not in
  the disclosed reference.
- **No silent pack adoption** (attended) — a pack outranks the baseline, so it is user-confirmed before going
  live (the `preferences.md` discipline).
- **No new priority tier** — packs generalize tiers 2 and 4; the locked cascade is unchanged.
- **No cross-pack weighted merge** — strict cascade, most-specific-match within a tier.

---

## 9. Open / next

- **[CONSEQUENCE — to implement]** Substrate hooks (§1 table): generalize the `swift-dev` tag/load points in
  `spec-to-tasks` + `task-execution` to `pack:<domain>`; add pack discovery to session start.
- **[CONSEQUENCE — to implement]** `swift-dev` re-manifested as `knowledge/ios/` (`pack.yml` + `baseline:
  true`); a compat note; `AGENTS.md` priority-chain wording widened (tiers 2 + 4).
- **[CONSEQUENCE — to implement]** `knowledge-ingest` skill + `/akios:learn` command (§5); routes to
  `pdf`/`pdf-reading`/`docx`/multimodal/`oss-first`.
- **[CONSEQUENCE — to implement]** `code-references/` reframed as the auto-built code pack (same INDEX,
  new framing); `preferences-and-priority.md` §2 annotated.
- **[DEPENDS ON]** `skill-authoring.md` (G3) authors both skills and packs through one path.
- **[OPEN — revisit after first packs]** within-tier pack precedence when two user packs match one task (§7).
- **[OPEN — revisit]** whether ingested-pack quality needs its own R-W-W-style audit (as `deep-brainstorm`
  audits specs) before a pack is trusted at tier 2.
