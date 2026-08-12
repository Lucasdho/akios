---
name: deep-brainstorm
description: Whole-subject mapping session — zooms out to the entire thing being made or investigated, enumerates every major dimension of it, scopes each one, and bursts out a complete family of versioned specs into akios/specs/ and akios/Roadmap.md. Works for a software product, a game, a creative work, a research question, a course, a business, or anything else with parts worth mapping. Use when the user wants the whole picture before starting, runs /akios:deep-brainstorm, says "map the whole thing", "let's design everything", "generate all specs", "mapeie tudo", "quero pensar isso a fundo", or wants a comprehensive backlog before execution. Runs interactively by default; unattended deepthink when called under just-vibes.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "2.0.0"
---

# Deep Brainstorm — Whole-Subject Mapping

You are running a **whole-subject discovery session**. The goal is to map every major dimension
of the thing, scope each area, and produce a **complete family of versioned specs** — one per
identified domain — that future `/akios:plan` + `/akios:deliver` runs can work from.

This skill **produces specs, not the work itself**. Every identified domain becomes an
`akios/specs/<domain>.md` registered in `akios/Roadmap.md` at status `designed`.

## The subject can be anything

**Do not assume software.** This session maps whatever the user brought: an application, a game,
a novel or an album, a course, a research question, a business, a physical build, a personal
system, a decision they're stuck on. The phases below are the same in every case; what changes is
the *vocabulary* — which dimensions exist, which questions are worth asking, what a "domain" is.

Three rules keep it open:

- **Take the subject on its own terms.** Never translate it into a software project to make the
  dimensions fit. A game has mechanics, not screens. An essay has arguments, not data models. If
  the honest map has four dimensions, it has four — don't pad it to six.
- **The lens decks below are starting points, not schemas.** Pick the closest deck, adapt it
  freely, or derive your own from the subject. Deriving one is the *normal* case for anything the
  decks don't name, not an exception you apologize for.
- **A dimension that doesn't apply is dropped, not filled.** An empty "Integrations" section on a
  poetry collection is noise. Say it doesn't apply and move on.

> **Mapping software?** The software lens has a full deck of its own — an 8-ingredient product
> Discover, the six map dimensions written out, the recurring spec groupings, and the two things a
> software spec must carry. **Read `references/software-lens.md` at Phase 1 and work from it**;
> the rows below are its compressed form. Everything else in this file still applies unchanged.

## The contract: what this skill owns

- Reads: `akios/Context.md`, `akios/Vision.md` (if present), `akios/Roadmap.md`, `MEMORY.md`,
  existing `akios/specs/*.md`. Nothing else without checking first.
- Writes: `akios/specs/*.md` (one per identified domain), updates `akios/Roadmap.md`.
- Does NOT: do the work itself — no code, no prose, no task files. Those belong downstream.

Each spec it produces flows through the normal `plan → deliver` pipeline as any
`/akios:brainstorm` spec would. After this session, `/akios:just-vibes --force` can work
the entire backlog autonomously.

---

## Phase 0 — Orient & name the subject (always, one short turn)

Read `akios/Context.md`, `akios/Vision.md`, `akios/Roadmap.md`, and any existing
`akios/specs/*.md`. Build a mental model of what this is, who it's for, and what's already
mapped.

Then greet the user in one short message: summarize what you found, and **say back what kind of
thing you understand this to be, in their words** ("this reads as a narrative game about grief" /
"this reads as an open research question about X"). Getting the kind wrong here mis-shapes every
phase after it, so name it explicitly and let them correct you cheaply. State what the session
will produce. Wait.

---

## Phase 1 — Discover (interactive or unattended)

**Purpose:** establish a shared, grounded understanding of the whole before mapping its parts.
One decision at a time. Follow `idea-to-spec`'s golden rules throughout.

**If the user has already run `founderlens-behavior`** (there's an `akios/specs/founderlens-*.md`
or `akios/Vision.md` has a completed first-diamond section): summarize the locked decisions, flag
tensions with `akios/Context.md`, and ask permission to skip to Phase 2. Wait.

**Otherwise:** walk these five, one per turn, using the `idea-to-spec` decision loop (up to 3
positions, recommendation pre-marked, open field always first-class). They hold for any subject:

| # | Ingredient | The question |
|---|---|---|
| 1 | **Core promise** | In one sentence, what is this and what does it do for whoever meets it? |
| 2 | **Who it's for** | The single most important audience — a concrete person, player, reader, or user. "Me" is a valid answer and changes the rest. |
| 3 | **Why it should exist** | The pain it relieves, the itch it scratches, the question it answers, the gap it fills. |
| 4 | **What exists already** | Web-search 2–3 real precedents — competitors, prior works, existing literature, other people's attempts. Key traits, and the gap they leave. Cite real names, never invent. |
| 5 | **The edge** | The one thing this does that the precedents don't do as well. |

Then add **one or two lens-specific ingredients** — the questions that matter for *this* kind of
thing and would be malpractice to skip:

| Lens | Add |
|---|---|
| Software / product | Business model (who pays, what triggers payment) · Distribution (how people first find it). **Use the fuller 8-ingredient set in `references/software-lens.md` instead of this row.** |
| Game | The core loop (what the player does over and over, and why it stays good) · The feel it's chasing |
| Creative work | Form and constraints (length, medium, rules you're binding yourself to) · The effect on the audience |
| Inquiry / research | The central question, stated so it could be answered wrongly · What evidence would change your mind |
| Business / operation | The unit economics · The bottleneck that decides whether it scales |
| Personal system | The failure mode it's designed against · What "still working in six months" looks like |
| Something else | Derive them: what would a thoughtful practitioner of *this* refuse to start without? |

At the seam, summarize the locked ingredients compactly. Flag any tension between them. Ask:
"Shall I move to the map phase, or is there anything to revisit?" Wait.

**Unattended (just-vibes):** deepthink every ingredient, web-search precedents, resolve by best
judgment, record each decision with its reasoning. Flag unverifiable assumptions as open risks.

---

## Phase 2 — Cartograph (the map)

**Purpose:** enumerate every major surface of the subject. This is a structured inventory, not a
design session — you're listing what exists and what needs to exist, not designing how it works.
Deep design happens later, in the individual spec sessions.

**First, choose the dimension deck.** State which you're using and why, in one line, and offer to
adjust before enumerating anything — the deck shapes the whole map, so it's cheap to fix now and
expensive later.

| Lens | Dimensions |
|---|---|
| **Software / product** | Screens & flows · Data domains · Infrastructure & services · Cross-cutting concerns (theming, a11y, localization) · Business logic & rules · Integrations — each written out with its candidates in `references/software-lens.md` |
| **Game** | Core systems & mechanics · Content (levels, encounters, items) · Player-facing surfaces · Progression & economy · Feel & feedback (juice, audio, pacing) · Technical foundations |
| **Creative work** | Pieces or sections · Motifs & throughlines · Medium & materials · Structure & sequence · Production steps · Reference corpus |
| **Inquiry / research** | Sub-questions · Evidence sources · Methods · Counter-positions & steelmen · Deliverables · Open threads |
| **Course / curriculum** | Learning outcomes · Modules · Exercises & assessment · Materials · Delivery format · Prerequisites |
| **Business / operation** | Offer · Customer journey · Operations & fulfilment · Money (pricing, costs, flow) · People & roles · Risk & compliance |
| **Something else** | Derive 4–7 dimensions from the subject itself. Ask: what are the genuinely different *kinds* of parts here, such that a decision inside one rarely changes another? Name them in the user's vocabulary. |

Work one dimension per turn. For each: propose the candidates you can infer from
`akios/Context.md` plus the Discover decisions, ask the user to add / remove / rename, then lock
the list.

After every dimension is locked, produce a **compact map** — one section per dimension, one
bullet per item. This is the source of truth for Phase 3.

**Capture boundaries and shared seeds while mapping, not later.** Two things otherwise get
rediscovered downstream: **boundaries** (when two items will need to talk to each other — flag
which owns the interaction and which consumes it) and **shared seeds** (recurring elements that
shouldn't be reinvented per-domain: a design system, a recurring motif, a shared method, a
standard rig). Express both in whatever vocabulary the subject already uses — for a software
project, `akios/Context.md` `## Architecture` names it.

---

## Phase 3 — Scope (priority triage)

**Purpose:** label every item with a priority tier so the spec family has a natural order.

Present the full map and propose a tier for each item, one dimension at a time:

| Tier | Meaning |
|---|---|
| `core` | Essential — the thing doesn't work, ship, or make sense without it |
| `enhance` | Important next — makes it competitive, complete, or good rather than adequate |
| `future` | Deferred — worth naming so it isn't forgotten, not worth doing yet |

**Grouping rule:** obviously-bundled items in the same dimension can share one tier — don't make
the user triage 40 items one by one. Propose groups; let them split if they disagree.

Show a compact scope summary (core: N · enhance: M · future: K), ask "Does this scope feel right?
Any surprises?", and wait. Offer a second pass.

---

## Phase 4 — Spec-burst (produce the spec family)

**Purpose:** translate the scoped map into a complete family of `akios/specs/*.md`. Each spec is
one coherent domain — the unit `spec-to-tasks` will later decompose. Carry the boundary and seed
notes from Phase 2 into each spec, where they get resolved into an actual declaration instead of
staying loose. In a software project with module boundaries, that resolution is the spec's
`## Contract` header (see `idea-to-spec`'s `references/akios-integration.md`).

### Grouping into specs

Not every item becomes its own spec. The rule: **one spec per area of related work that can be
planned and worked independently.** How that lands depends on the subject — an app groups by
`onboarding` / `search` / `infra-auth` / `design-system` (the full table is in
`references/software-lens.md`); a game by `combat-core` / `enemy-roster` / `save-system`; a book by
`act-one` / `research-1920s` / `voice-and-style`; an inquiry by `evidence-base` /
`counterarguments` / `final-write-up`.

Propose the grouping in one turn — each candidate spec named, one line each. Ask if any should be
split, merged, or renamed. Wait.

### Writing the specs

Once grouping is confirmed, write all specs **in one pass** — never one at a time with approval
between. Each follows `idea-to-spec`'s `references/spec-format.md` (scaffolded from
`templates/spec.md`), filling in:

- **Status:** `designed`
- **Priority tier:** `core` / `enhance` / `future` (from Phase 3)
- **What it covers:** 3–5 bullets naming the items in scope.
- **What it does NOT cover:** explicit out-of-scope items — this is what stops drift later.
- **Key decisions:** the Phase 1–3 decisions that directly constrain this spec.
- **Open questions:** anything genuinely unresolved. Better named now than hit mid-execution.
- **Worked example:** one concrete run through this spec end to end — a user action, a turn of
  play, a passage, a worked case.
- **States** (any spec with an interactive or data-backed surface): happy · empty · loading ·
  error. Skip the section entirely when the domain has no such surface.

Leave implementation notes blank — those belong to `spec-to-tasks`.

### After writing

Update `akios/Roadmap.md`: one row per spec, status `designed`, with its priority tier. Preserve
existing rows; never reorder them.

---

## Phase 5 — Validate (R-W-W audit)

Score each spec from Phase 4 on three dimensions. The rubric is deliberately coarser than
`founderlens-behavior`'s per-idea Midpoint Validation Audit — it's scoring a *slice* of something
already chosen, not validating an idea from scratch.

| Dimension | Criterion | Max |
|---|---|---|
| **Real** | Does this domain address a genuine need, pain, or question? Is its scope grounded in the Discover decisions rather than invented here? | 30 |
| **Win** | Can it be done within the stated constraints — skill, tools, time, budget, stack? Does it deliver the edge identified in Discover? | 40 |
| **Worth It** | Is the effort justified by the value? Can it be decomposed into one `spec-to-tasks` session rather than being a project of its own? | 30 |

**Bands:** 71–100 Green (proceed) · 41–70 Yellow (shaky, proceed with caution) · 0–40 Red (needs revision).

**Score honestly, not kindly.** A domain with no grounded evidence of need scores low
on Real. A scope-unbounded domain scores low on Worth It. Name the specific weakness and pair it
with a one-line remediation hint.

Write (or overwrite) `akios/specs/rww-audit.md`:

```markdown
# R-W-W Spec Audit
Generated by /akios:deep-brainstorm Phase 5.

| Spec | Real /30 | Win /40 | Worth It /30 | Total | Band | Action | Note |
|---|---|---|---|---|---|---|---|
| <spec-name>.md | <score> | <score> | <score> | <total> | Green/Yellow/Red | — / [audit: shaky] / needs-revision | <one-line note> |
```

Then update `akios/Roadmap.md`: **Red** → status `needs-revision`; **Yellow** → keep `designed`,
append `[audit: shaky]` to Notes; **Green** → no change.

Interactively: show the table, explain every Red and Yellow, wait for acknowledgement. The user
may override a score — record the override and its reason in the audit file. Under just-vibes:
derive scores from the Discover decisions and spec content, record the reasoning per spec, update
the Roadmap silently, and log the summary (X green, Y shaky, Z need revision) in the journal.

---

## Phase 6 — Review & close

Present a compact summary:
- **Map:** dimensions enumerated, total items.
- **Scope:** how many core / enhance / future.
- **Specs produced:** name + file path + tier.
- **Audit result:** Green / Yellow / Red counts; which specs need revision.
- **Open questions across all specs:** one consolidated list — what the user must decide before
  or during execution.
- **Suggested order:** core items with fewest dependencies first; Red specs excluded until revised.
- **Next step:** `/akios:just-vibes --force` for the whole backlog, or `/akios:plan <spec>` for one.

If two specs make conflicting assumptions, flag it explicitly here — name both sides, propose a
reconciliation, wait.

---

## The golden rules (inherited from `idea-to-spec`)

1. **One thing at a time.** One dimension, one decision, one confirmation per turn. End almost
   every turn by handing control back.
2. **Propose, then check.** Up to 3 positions, recommendation pre-marked with its reason. Open
   field always first-class. Never decide silently.
3. **Grounded, never invented.** Precedents come from web search and are cited. If you can't
   verify it, flag it as unverified.
4. **Honesty over harmony.** Flag tensions between the user's own decisions instead of smoothing
   them over.
5. **Mirror the user's language.** This skill is in English; the session runs in whatever language
   the user speaks.

---

## Unattended (just-vibes)

- Run all 6 phases without stopping for input.
- **Deepthink every material decision** (the lens, the dimensions, groupings, scoping, spec
  boundaries). Record why.
- **Web-search** precedents and any external fact that would change a decision.
- **Resolve by best judgment.** Where genuinely 50/50, choose the reversible option.
- **Flag, don't smooth.** Tensions and unverifiable assumptions become marked open risks in the
  relevant spec, for the human to triage on review.
- Produce all specs, update `akios/Roadmap.md`, then report and stop (or yield to the loop).

---

## Anti-patterns

- **Forcing the subject into a software shape** — inventing screens for a novel, data models for a
  research question. Map what's actually there.
- **Using a lens deck as a checklist to fill** — an empty dimension is a finding, not a blank to
  complete.
- Doing the work mid-session ("I'll just draft the opening paragraph here") — stay in spec mode.
- Writing one spec and asking for approval before the next — the spec-burst is one pass.
- Grouping everything into one mega-spec — a domain no one person can hold in their head is too big.
- Leaving `Open questions` blank to seem decisive — naming the unknowns is what saves execution.
- Inventing precedents — web-search and cite, or don't cite.
