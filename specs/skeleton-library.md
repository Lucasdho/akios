# akios — Skeleton Library (architecture-keyed project starters)
**Working spec · v1.0 · knowledge-architecture family · 2026-07-01**

Promotes the skeleton sketch from `snippet-library.md` §7 into its own spec. A **skeleton** is a
full starting project tree, keyed by **architecture type**, that `/akios:init` can drop into a
brand-new repo instead of an empty scaffold — the oneshot's "solid base" the user asked for. Different
skeletons exist for different architectures (ALVA, MVVM-C, Clean, or anything else the user names);
at init time, the user picks an architecture and gets that architecture's skeleton **if one is
registered** — otherwise the default plugin scaffold, unchanged. Complements `snippet-library.md`
(the sibling mechanism for reusable *pieces*, not whole trees) and `knowledge-architecture.md` (whose
user-global storage convention this reuses). Registers backlog **B31** (`akios-backlog-map.md` §11).

> **State:** designed — mechanism only, same posture as `snippet-library.md`: no skeleton content is
> populated by this pass.

> **Autonomous decision pass:** at the user's explicit request, the remaining open decisions in this
> spec (§1–§6) were resolved **autonomously**, `/akios:just-vibes`-style — the recommended position
> was taken for each, alternatives are recorded with why they were rejected, and second-order
> consequences are noted so the user can override anything on read rather than re-deriving it. Nothing
> here is more final than any other `designed` spec; it is simply un-reviewed by a human yet.

---

## 1. Keying scheme — free-form `architecture:` tag (D1)

**Decided (recommended position, user-confirmed before the autonomous pass started):** each skeleton
carries a free-form `architecture:` string in its manifest (`alva`, `mvvm-c`, `clean`, `layer-first`,
or anything the user names) — not a fixed enum. More than one skeleton may share a tag (variants), e.g.
`alva-minimal` and `alva-with-supabase` both tagged `alva`.

- **Rejected:** a closed vocabulary matching only the two architectures akios itself currently names
  (`alva`, `layer-first`, per `akios-backlog-map.md` §4). Rejected because "different skeletons for
  different architecture types" reads as open-ended — locking the tag to akios's own two opinions would
  block a user-authored MVVM-C or Clean-Architecture skeleton that akios has no doctrine about.
- **Reversible:** yes — a curated list of "recommended tags" could be layered on top later (e.g. for
  autocomplete) without breaking anything free-form already registered.

---

## 2. Manifest shape (D5, decided autonomously)

Mirrors `pack.yml`'s shape (`knowledge-architecture.md` §2) for consistency — "reuse what shipped
well" rather than inventing a third schema style in the same family:

```
~/.claude/akios/skeletons/
  alva-minimal/
    manifest.yml
    <full project tree — Xcode project, Router/, Container/, Foundation/, one example Features/ slice>
  alva-with-supabase/
    manifest.yml
    <same shape, with a Supabase-backed repository already wired>
  mvvm-c-basic/
    manifest.yml
    <MVVM-C tree>
```

`manifest.yml`:
```yaml
name: alva-minimal
architecture: alva
description: "Minimal ALVA vertical-slice starter — Router/Container/Foundation stubs, one example Feature slice"
stack: "Swift 6 / SwiftUI / SwiftData"
version: "0.1.0"
provenance:
  - {source: "~/Projects/AppX", kind: project, extracted: 2026-07-01}
```

**Decision & reason:** reusing the pack manifest shape means a user who already understands
`pack.yml` reads this with zero new vocabulary. `provenance` is kept for the same reason
`snippet-library.md` keeps it — traceability back to whichever real project a skeleton was lifted from.

---

## 3. When the selection step runs (D2, decided autonomously)

**Decided:** the skeleton-selection step runs **only** inside `/akios:init`'s fresh-repo path
(`commands/init.md` §0, the "no version file → fresh repo" branch) **and only when the resolved
`Mode` is `new`** (greenfield). It does not run for `feature` or `one-shot` onto an existing app.

- **Reason:** a skeleton is a whole file tree; offering to drop one into a repo that already has code
  (`feature`/`one-shot` mode, or a migrate-path re-run per `init.md` §0's "Recorded < installed"
  branch) risks clobbering existing files — a hard-to-reverse action presented in a context where it
  never makes sense. Gating on `mode: new` means the option is never even shown where it would be
  destructive.
- **Rejected alternative:** always ask regardless of mode, with an explicit "repo already has files,
  skip?" guard at copy time. Rejected as needless risk-surface for a case (`new` vs. not) `init.md`
  already resolves cleanly one step earlier — no reason to reopen the danger the mode question already
  closed.
- **Reversible:** yes, loosening the gate later (e.g. to support "re-scaffold a subfolder") is a small
  , additive change.

---

## 4. Selection flow — folds into the existing interview, doesn't duplicate it (D3, D3b, decided autonomously)

`commands/init.md` §1 already asks an **"Architecture"** interview question ("one paragraph: entry
points, key dirs, data flow") — today aimed at describing an *existing* repo's structure for `Context.md`.
For a fresh `mode: new` repo there is no existing structure to describe yet, so this spec **folds the
skeleton pick into that same question** instead of adding a second, redundant one:

1. Immediately after `Mode` resolves to `new` (§1 of `init.md`), list the distinct `architecture:`
   tags found across `~/.claude/akios/skeletons/*/manifest.yml`, plus an explicit **"none / default
   scaffold"** option.
2. If exactly one skeleton matches the chosen tag, use it directly. If more than one matches
   (variants), show just those by `name` for a second, narrower pick.
3. **The chosen skeleton's `description:` + `stack:` pre-fill the existing "Architecture" interview
   answer** (still user-editable) — so `Context.md` ends up populated from the skeleton's own manifest
   instead of the user re-typing a paragraph that describes exactly what they just picked.
4. If **zero skeletons are registered anywhere**, the question is skipped entirely — never present a
   choice with no real options — and the existing free-text "Architecture" question runs exactly as it
   does today.

**Decision & reason:** grouping by tag first (rather than a flat list of skeleton names) keeps the
question short as variants accumulate. Pre-filling the existing Architecture field (rather than adding
a parallel one) avoids two questions doing overlapping work — closes the loop with zero new
redundant prompts, which is the same instinct that made `knowledge-architecture.md` reuse
`swift-dev`'s guide shape instead of inventing a new one.

---

## 5. Ordering inside `/akios:init` — copy before scan (D6, decided autonomously)

**Decided:** if a skeleton is chosen, its file tree is copied into the repo root **before** `init.md`
§2 (Scan) runs, and before §3 (Materialize context files) writes `Context.md`/`AGENTS.md`/etc.

- **Reason:** §2's scan inspects the repo (`.xcodeproj`, `Package.swift`, deployment target, top-level
  dirs) to fill `Context.md` with real facts. If the skeleton's files land *after* the scan, the scan
  runs against an empty repo and `Context.md` describes nothing — exactly backwards. Copying first
  means the scan sees the real, chosen starting structure and `Context.md` reflects it truthfully.
- **Rejected alternative:** copy last, after context files are written. Rejected for the reason above —
  it produces an internally inconsistent `Context.md` (says "TBD" or empty where the skeleton already
  answers it).
- **Reversible:** yes, a straightforward ordering change if it ever proves wrong in practice.

---

## 6. Boundary with akios's own meta files — never shipped by a skeleton (deliberate exclusion, decided autonomously)

**Decided:** a skeleton's tree covers the **app's own source** (Xcode project, `Router/`, `Container/`,
`Foundation/`, example `Features/` slice, or whatever the architecture calls for) and **never** ships
its own `AGENTS.md`, `Context.md`, `Roadmap.md`, `Vision.md`, or `.claude/` — those always come from
the plugin's own templates (`init.md` §3), applied after the skeleton copy (§5).

**Decision & reason:** keeps exactly one source of truth for the akios meta files regardless of which
skeleton was chosen — a skeleton that shipped its own `Context.md` would either collide with the
plugin's template or fork the format; excluding it outright removes the collision instead of resolving
it case by case.

---

## 7. Worked example — futebol-manager, greenfield

User runs `/akios:init` on an empty repo. `Mode` resolves to `new`. Two skeletons exist:
`alva-minimal` (`architecture: alva`) and `mvvm-c-basic` (`architecture: mvvm-c`). The init flow lists
`alva` and `mvvm-c` as the two available tags; the user picks `alva`; only one skeleton matches, so
`alva-minimal` is used directly. Its tree (Xcode project + `Router/`/`Container/`/`Foundation/` stubs +
one example `Features/Squad/` slice) is copied in **before** the scan runs; the scan then finds the
real `.xcodeproj`, fills `Context.md`'s Xcode-target section from it, and the "Architecture" interview
answer is pre-filled from `alva-minimal`'s `description:` ("Minimal ALVA vertical-slice starter…"),
which the user accepts as-is. `AGENTS.md`/`Context.md`/`Roadmap.md` come from the plugin templates as
always — none of them were part of the skeleton.

---

## 8. Empty / edge states

- **Zero skeletons registered anywhere:** the tag question is skipped; the existing free-text
  "Architecture" interview question runs unchanged (today's behavior, zero regression).
- **Exactly one skeleton for the chosen tag:** used directly, no second pick.
- **Multiple skeletons share a tag (variants):** a second, narrower pick by `name` only.
- **User explicitly picks "none / default scaffold"** even though skeletons exist: the plugin's own
  default scaffold is used, exactly as it works today — a skeleton is never forced.
- **Mode is `feature` or `one-shot` (not `new`):** this entire step does not run (§3/D2) — repo already
  has code, nothing to scaffold.
- **Chosen architecture tag has no registered skeleton at all** (the user names a tag in the list that
  turns out to be empty, or types one that doesn't exist): falls straight through to the default
  scaffold — matches the user's own framing verbatim ("usa o esqueleto daquela arquitetura se
  houver").

---

## 9. Deliberate exclusions

- **No skeleton ships akios's own meta files** (§6) — always sourced from the plugin's templates.
- **No architecture migration tooling.** Switching a project from one architecture's skeleton to
  another after the fact is a manual, human-led rewrite — this mechanism only seeds day zero.
- **No content curation in this pass.** Same posture as `snippet-library.md`: the mechanism is
  designed; populating real skeleton trees (an actual ALVA starter, an actual MVVM-C starter) is
  deferred, explicit future manual work.
- **No update-in-place for already-scaffolded projects.** A skeleton copied into a repo is a
  point-in-time copy; updating the registered skeleton later doesn't retroactively touch repos already
  created from it — same semantics `snippet-library.md` §10 already states for snippets.

---

## 10. Backlog placement

Registered as **B31** in `akios-backlog-map.md` §1 (new line, this session, same exception noted for
B30 — not from the original raw list), theme **"Knowledge / starter content"** (same theme as B30, kept
as a distinct ID since the user explicitly wants snippets and skeletons tracked separately). Added to
§3 as **G8**:

| # | New spec | Answers | One-line thesis |
|---|---|---|---|
| G8 | `skeleton-library.md` | B31 | Architecture-keyed whole-project starter trees for `/akios:init`'s greenfield path — user picks an architecture, gets that architecture's skeleton if one is registered, else today's default scaffold. |

**Sequencing:** depends on nothing new beyond the user-global storage convention `knowledge-architecture.md`
already establishes (this spec doesn't reuse the pack format itself — skeletons are explicitly outside
it, per `snippet-library.md` §7's original reasoning — only the "lives under `~/.claude/akios/`"
convention). Independent of `snippet-library.md`'s own build (G7); the two can ship in either order.
`akios-backlog-map.md` §5 build order gets a new line after step 5 (`snippet-library.md`): step 6
(`skeleton-library.md`, G8), pushing the former steps 6–7 down by one.

`Roadmap.md` gets a new row: `skeleton-library.md` | domain "Architecture-keyed project skeletons for
`/akios:init` greenfield path" | status `designed` | notes "backlog B31; sibling to snippet-library.md
(promoted from its §7 sketch); no shared build dependency between the two."

---

## 11. Open / next

- **[CONSEQUENCE — to implement, once built]** `commands/init.md` needs: (a) the tag-listing +
  second-level pick inserted into §1 right after `Mode` resolves `new` (§4); (b) the skeleton copy
  spliced between §2 (Scan) and §1's architecture pre-fill lands before §3 (Materialize) writes
  `Context.md` (§5); (c) the §6 self-check gains one more check — no skeleton-sourced file overwrote
  `AGENTS.md`/`Context.md`/`Roadmap.md`/`Vision.md`/`.claude/`.
- **[MANUAL WORK — explicitly deferred by the user]** Curating actual skeleton trees (an ALVA starter,
  an MVVM-C starter, etc.) is future work, done incrementally, same posture as `snippet-library.md`.
- **[OPEN — flagged, not resolved]** No ingestion path is designed for skeletons (unlike snippets'
  `/akios:learn --kind snippet`, `snippet-library.md` §6) — today a skeleton would have to be hand-
  assembled at `~/.claude/akios/skeletons/<name>/`. If this proves too manual once the user starts
  populating skeletons, revisit with an `/akios:learn --kind skeleton <project-path>` extension
  mirroring §6 of `snippet-library.md`. Left open deliberately rather than designed now, since the
  user has not asked for it and the shape of "what to strip from a real project to make it a clean
  starter" is a real, non-trivial question of its own.
- **[ASSUMES]** Same fork dependency `snippet-library.md` §12 already notes: if the ALVA-vs-layer-first
  fork (`akios-backlog-map.md` §4) reopens against ALVA, an `alva`-tagged skeleton's internal shape
  would need remodeling — the *tagging mechanism* here is unaffected either way, since tags are
  free-form (§1) and don't hardcode ALVA's folder law anywhere in this spec.
