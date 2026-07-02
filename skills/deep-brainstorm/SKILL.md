---
name: deep-brainstorm
description: Whole-app mapping session — runs the FounderLens Double Diamond on the entire product, cartographs every major surface area (screens, data domains, flows, infrastructure), scopes each area (core/enhance/future), and bursts out a complete family of versioned specs into specs/ and Roadmap.md. Use when the user wants to map the full app before building, runs /akios:deep-brainstorm, says "map the whole app", "let's design everything", "generate all specs", "mapeie o app inteiro", or wants a comprehensive backlog before starting feature execution. Runs interactively by default; unattended deepthink mode when called under just-vibes.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Deep Brainstorm — Whole-App Mapping

You are running a **whole-product discovery session**. The goal is to map every major surface
of the app, scope each area, and produce a **complete family of versioned specs** — one per
identified domain — that future `/akios:plan` + `/akios:deliver` runs can build from.

This skill **does not write app code**. It writes specs. Every identified domain becomes a
`specs/<domain>.md` registered in `Roadmap.md` at status `designed`.

## The contract: what this skill owns

- Reads: `Context.md`, `Vision.md` (if present), `Roadmap.md`, `MEMORY.md`, existing `specs/*.md`.
  Nothing else without checking first.
- Writes: `specs/*.md` (one per identified domain), updates `Roadmap.md`.
- Does NOT: write app code, task files, or data files — those belong to the deliver pipeline.

## Relation to the existing pipeline

Deep brainstorm is a **pre-execution cartography pass**: it zooms out to the whole product,
then each spec it produces flows through the normal `plan → deliver` pipeline as any
`/akios:brainstorm` spec would. After this session, `/akios:just-vibes --force` can build
the entire backlog autonomously.

---

## Phase 0 — Orient (always, one short turn)

Read `Context.md`, `Vision.md`, `Roadmap.md`, and any existing `specs/*.md`. Build a mental
model of:
- What the app does and who it's for.
- What's already specced / built / planned.
- What the user just passed as an argument (if any).

Then greet the user in one short message: summarize what you found (app name, existing specs
count, current state), state what this session will produce, and confirm they're ready to
start. Wait.

---

## Phase 1 — Discover (interactive or unattended)

**Purpose:** Establish a shared, grounded understanding of the whole product before mapping
its parts. One decision at a time. Follow `idea-to-spec`'s golden rules throughout.

**If the user has already run `founderlens-behavior`** (there's a `specs/founderlens-*.md`
or `Vision.md` has a completed first-diamond section): summarize the locked decisions,
flag any tensions with the existing `Context.md`, and ask permission to skip straight to
Phase 2 (Cartograph). Wait.

**Otherwise:** run the Discover phase inline, adapted for whole-app mapping. Walk through
these 8 ingredients, one per turn, using the `idea-to-spec` decision loop (up to 3 positions,
recommendation pre-marked, open field always available). This is a deliberately smaller set than
`founderlens-behavior`'s 10-ingredient Discover: that skill validates one startup idea from
scratch (needs Frequency/WTP/Trigger to test willingness-to-pay); this one maps domains inside an
**already-chosen** app, so it drops those three and adds Business model/Distribution instead —
not drift, a different question being asked:

| # | Ingredient | The question |
|---|---|---|
| 1 | **Core promise** | In one sentence, what does this app do for its user? |
| 2 | **Primary persona** | Who is the single most important user today? (concrete person, not a segment) |
| 3 | **Acute pain** | What specific pain does that person have right now that this app relieves? |
| 4 | **Today's alternative** | What do they use instead today, and why is it worse? |
| 5 | **Unique advantage** | What is the one thing this app does that no alternative does as well? |
| 6 | **Business model** | How does this app sustain itself? (revenue model, who pays, what triggers payment) |
| 7 | **Distribution** | How do users first find and install the app? |
| 8 | **Benchmark** | Web-search for 2–3 real competitors. Key features, pricing, the open gap. Cite real names — never invent. |

At the seam, summarize the 8 locked ingredients compactly. Flag any tension between them.
Ask: "Shall I move to the map phase, or is there anything to revisit?" Wait.

**Unattended (just-vibes) mode:** deepthink every ingredient. Web-search the Benchmark.
Resolve via your best judgment, record every decision with its reasoning in the first-diamond
spec. Flag unverifiable assumptions as open risks.

---

## Phase 2 — Cartograph (the app map)

**Purpose:** Enumerate every major surface of the app. This is a structured inventory, not
a design session — you're listing what exists and what needs to exist, not designing how it
works. Deep design happens in the individual spec sessions.

Work through these 6 dimensions. For each, propose a list of candidates (what you can infer
from Context.md + the Discover decisions), ask the user to add, remove, or rename, then lock
the list. One dimension per turn.

### The 6 dimensions

**1. Screens & flows**
List every distinct screen (or major flow). Group by section (e.g., Onboarding · Home ·
Detail · Settings · Profile). Example: `Home Feed`, `Item Detail`, `Search`, `Settings —
Notifications`, `Onboarding — Step 1: Welcome`.

**2. Data domains**
List every major data entity or model (e.g., `User`, `Post`, `Comment`, `Session`, `Notification`).
Include sync/persistence concerns where obviously distinct (e.g., `LocalDraft` vs `PublishedPost`).

**3. Infrastructure & services**
List every non-UI technical concern: Auth, Networking/API, Push Notifications, Analytics,
Crash Reporting, In-App Purchase, CloudKit/Sync, Background Tasks, Keychain, etc.

**4. Cross-cutting concerns**
Things that touch every screen but live in no one spec: Theming/Design System, Accessibility,
Localization (which languages?), Deep Links / Universal Links, Widget / Extension.

**5. Business logic & rules**
Non-trivial logic that isn't a screen or a data model: Recommendation algorithm, Pricing
rules, Content moderation, Permission/role logic, Rate limiting, Paywall gating.

**6. Integrations**
Third-party APIs, SDKs, or external services: Stripe, Firebase, RevenueCat, Algolia, Maps,
Camera/Photo Library, HealthKit, Sign in with Apple, etc.

After all 6 dimensions are locked, produce a **compact app map** — one section per dimension,
one bullet per item. This is the source of truth for Phase 3.

**Slice cartography (ALVA).** Each item that will become its own buildable domain is a future
`Features/<Domain>/` slice, not a shared layer — note this while mapping, not as an afterthought
later. Two things to capture right here:
- **Contract boundaries.** When two items on the map will need to talk to each other (e.g. "Home
  Feed" needs `User`'s auth state), mark which owns the *intention* (doctrine §5.4) and which side
  will consume the other via `contract/`. Don't resolve every cross-reference now — just flag them
  so Phase 4 doesn't have to rediscover them.
- **Foundation seeds.** Cross-cutting items from dimension 4 (Theming/Design System, shared
  utilities) are `Foundation/` candidates from day one — call them out so the spec family doesn't
  reinvent them per-domain.

---

## Phase 3 — Scope (priority triage)

**Purpose:** Label every item on the app map with a priority tier so the spec family has
a natural build order.

Present the full app map (from Phase 2) and propose a tier for each item. One dimension at
a time, ask the user to confirm or adjust:

| Tier | Meaning |
|---|---|
| `core` | MVP-critical — the app doesn't work without it |
| `enhance` | Important post-MVP — makes the app competitive |
| `future` | Nice to have — defer until core + enhance ship |

**Grouping rule:** items within the same dimension that are obviously bundled (e.g., all
Onboarding screens) can share one tier label — don't force the user to triage 40 items one
by one. Propose groups; let the user split if they disagree.

After all items are tiered, show a compact **scope summary**:
- Core: N items
- Enhance: M items
- Future: K items

Ask: "Does this scope feel right? Any surprises?" Wait. Offer a second pass if they want
to shuffle anything.

---

## Phase 4 — Spec-burst (produce the spec family)

**Purpose:** Translate the scoped app map into a complete family of `specs/*.md` files.
Each spec represents one coherent domain — the unit that `spec-to-tasks` will later decompose
into an ALVA feature slice (`Features/<Domain>/{domain,data,presentation,contract,tests}`). Carry
forward the contract-boundary and Foundation-seed notes from Phase 2 into each spec's Contract &
Foundation header (`idea-to-spec`'s `spec-format.md`) — this is where those flags get resolved
into an actual declaration instead of staying loose notes.

### Grouping into specs

Not every item on the app map becomes its own spec. Group by domain — the rule is:
**one spec per area of related work that can be planned and built independently**. Typical
groupings:

| Domain | What it usually covers |
|---|---|
| `onboarding` | All onboarding screens + auth flow |
| `home` | Home screen + core feed/list |
| `<feature>-detail` | Detail screen + related actions |
| `search` | Search UI + search infrastructure |
| `data-<entity>` | One major data model + its repository |
| `infra-auth` | Auth service (separate from onboarding UI) |
| `infra-networking` | API client, error handling, retry |
| `infra-notifications` | Push setup + notification handling |
| `settings` | Settings screens |
| `design-system` | Theme, typography, shared components |

Propose the grouping to the user in one turn: list each candidate spec by name, one line
each. Ask if any should be split, merged, or renamed. Wait.

### Writing the specs

Once grouping is confirmed, write all specs **in one pass** — do not write one at a time
and ask for approval after each. Each spec follows the `templates/spec.md` format.

For each spec, fill in:
- **Status:** `designed`
- **Priority tier:** `core` / `enhance` / `future` (from Phase 3)
- **What it covers:** 3–5 bullets naming the screens, models, or concerns in scope.
- **What it does NOT cover:** explicit out-of-scope items (reduces drift in the deliver phase).
- **Key decisions:** any decisions made in Phase 1–3 that directly constrain this spec.
- **Open questions:** anything genuinely unresolved — better to name them now than hit them
  during task-execution.
- **Worked example:** one concrete user action that exercises this spec end-to-end.
- **Empty / error states** (mandatory for any UI-touching spec): list happy · empty ·
  loading · error states for each major screen in scope.

Leave `Implementation notes` blank — those belong in spec-to-tasks.

### After writing

Update `Roadmap.md`: add a row per spec to the `## Specs` table with status `designed` and
its priority tier. Preserve any existing rows; never reorder them.

---

## Phase 5 — Validate (R-W-W audit)

> This is a **deliberately coarser variant** of FounderLens's per-idea Midpoint Validation Audit
> (`founderlens-behavior/references/app-behavior.md`) — 3 bands instead of 6, coarser weights.
> It's scoring an app-map **domain** (a slice of an already-chosen product) rather than validating
> a single startup idea from scratch, so the finer-grained WTP/Feasibility/Distribution split
> doesn't apply the same way. Same spirit (Real/Win/Worth-It, honesty over flattery), intentionally
> different rubric — not a drift to reconcile.

Score each spec produced in Phase 4 against three dimensions:

| Dimension | Criterion | Max |
|---|---|---|
| **Real** | Does this domain address a genuine gap / pain in the user's workflow? Is the scope grounded in Context.md / Vision.md / the Discover decisions? | 30 |
| **Win** | Can this domain be built within the app's stated constraints (stack, no-external-deps, team size)? Does it differentiate vs. alternatives identified in Discover? | 40 |
| **Worth It** | Is the execution effort justified by the value delivered? Can it be decomposed into one `spec-to-tasks` session (not a multi-month project)? | 30 |

**Bands:** 71–100 Green (proceed) · 41–70 Yellow (shaky, proceed with caution) · 0–40 Red (needs revision).

**Scoring posture:** honesty over flattery. A spec covering infrastructure with no grounded
user-pain evidence scores low on Real. A scope-unbounded spec scores low on Worth It.
Name the specific weakness; pair with a one-line remediation hint.

### Write `specs/rww-audit.md`

Write (or overwrite) a consolidated audit file in the target project:

```markdown
# R-W-W Spec Audit
Generated by /akios:deep-brainstorm Phase 5.

| Spec | Real /30 | Win /40 | Worth It /30 | Total | Band | Action | Note |
|---|---|---|---|---|---|---|---|
| <spec-name>.md | <score> | <score> | <score> | <total> | Green/Yellow/Red | — / [audit: shaky] / needs-revision | <one-line note> |
```

### Update `Roadmap.md`

- **Red (0–40):** change spec's status from `designed` to `needs-revision`.
- **Yellow (41–70):** keep status `designed`; append `[audit: shaky]` to the Notes column.
- **Green (71–100):** no change.

### Announce the audit result

In interactive mode: show the `rww-audit.md` table, explain any Red or Yellow scores, wait
for acknowledgement before moving to Phase 6. The user may manually override a score — record
the override and its reason in `rww-audit.md`.

In unattended (just-vibes) mode: derive scores from Discover-phase decisions + spec content;
record reasoning per spec in the audit file; update Roadmap.md silently; log audit summary
(X green, Y shaky, Z need revision) in the just-vibes journal.

---

## Phase 6 — Review & close

Present a compact summary:
- **App map:** dimensions enumerated, total items.
- **Scope:** how many core / enhance / future.
- **Specs produced:** list by name + file path + tier.
- **Audit result:** how many Green / Yellow / Red; which specs need revision.
- **Open questions across all specs:** a single consolidated list — these are the things the
  user needs to decide before or during execution.
- **Suggested execution order:** which specs to build first (core items with fewest dependencies,
  Green/Yellow specs only — Red specs are excluded until revised).
- **Next step:** `/akios:just-vibes --force` to build the full backlog autonomously, or
  `/akios:plan <spec>` to start one spec.

If there are tensions between specs (two specs that make conflicting assumptions), flag them
explicitly here — name both sides, propose a reconciliation, wait.

---

## The golden rules (inherited from `idea-to-spec`)

These bind throughout this skill:

1. **One thing at a time.** One dimension, one decision, one confirmation per turn.
   End almost every turn by handing control back.
2. **Propose, then check.** Up to 3 positions, recommendation pre-marked with its reason.
   Open field always first-class. Never decide silently.
3. **Grounded, never invented.** The Benchmark uses web search. Competitor claims are cited.
   If you can't verify it, flag it as unverified.
4. **Honesty over harmony.** Flag tensions between the user's own decisions instead of
   smoothing them over.
5. **Mirror the user's language.** This skill is in English; the session runs in whatever
   language the user speaks.

---

## Unattended (just-vibes) posture

When called under `/akios:just-vibes`:
- Run all 6 phases without stopping for user input.
- **Deepthink every material decision** (groupings, scoping, spec boundaries). Record why.
- **Web-search the Benchmark** and any competitor/platform facts that would change a decision.
- **Resolve via best judgment.** Where genuinely 50/50, choose the reversible option.
- **Flag, don't smooth.** Tensions and unverifiable assumptions get marked as open risks in
  the relevant spec. The human triages them when they review.
- Produce all specs + update Roadmap.md. Then report and stop (or yield to just-vibes loop).

---

## Anti-patterns

- Writing app code mid-session ("I'll just stub the model here") — stay in spec mode.
- Writing one spec and asking for approval before writing the next — the spec-burst is one pass.
- Grouping everything into one mega-spec — a domain no one person can hold in their head is too big.
- Leaving `Open questions` blank to seem decisive — naming the unknowns now is what saves the deliver phase.
- Inventing competitor data — web-search and cite, or don't cite.
